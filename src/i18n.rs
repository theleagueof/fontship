use crate::config::CONF;

use fluent::{FluentArgs, FluentBundle, FluentResource, FluentValue};
use fluent_fallback::{
    env::LocalesProvider,
    generator::{BundleGenerator, FluentBundleResult},
    types::{ResourceId, ResourceType},
    Localization,
};
use fluent_langneg::{accepted_languages, negotiate_languages, NegotiationStrategy};
use futures::stream::Stream;
use regex::Regex;
use rust_embed::RustEmbed;
use rustc_hash::FxHashSet;
use std::borrow::Cow;
use std::ops::Deref;
use std::path::{Component, Path, PathBuf};
use std::str;
use std::sync::RwLock;
use std::vec::IntoIter;
use unic_langid_impl::LanguageIdentifier;

// List of Fluent resource filenames to scan for keys from each locale directory.
static FTL_RESOURCES: &[&str] = &["cli.ftl"];

/// Embed everything in the assets folder directly into the binary
#[derive(RustEmbed)]
#[folder = "assets/"]
pub struct Asset;

lazy_static! {
    /// List of Locales in order of closeness to the runtime config
    pub static ref LOCALES: RwLock<Locales> =
        RwLock::new(Locales::new(CONF.get_string("language").expect("Unable to retrieve language from config")));
}

/// A prioritized locale fallback stack
#[derive(Debug)]
pub struct Locales(Vec<LanguageIdentifier>);

impl Deref for Locales {
    type Target = Vec<LanguageIdentifier>;
    fn deref(&self) -> &Vec<LanguageIdentifier> {
        &self.0
    }
}

impl Locales {
    /// Negotiate a locale based on user preference and what we have available
    pub fn new(language: String) -> Locales {
        let language = normalize_lang(&language);
        let available = self::list_available_locales();
        let requested = accepted_languages::parse(&language);
        let default: LanguageIdentifier = crate::DEFAULT_LOCALE
            .parse()
            .expect("Unable to parse default locale");
        Locales(
            negotiate_languages(
                &requested,
                &available,
                Some(&default),
                NegotiationStrategy::Filtering,
            )
            .iter()
            .copied()
            .cloned()
            .collect(),
        )
    }
}

impl LocalesProvider for Locales {
    type Iter = <Vec<LanguageIdentifier> as IntoIterator>::IntoIter;
    fn locales(&self) -> Self::Iter {
        self.0.clone().into_iter()
    }
}

/// A Fluent key plus any variables that will be needed to format it.
#[derive(Debug)]
pub struct LocalText<'a> {
    key: String,
    args: Option<FluentArgs<'a>>,
}

impl<'a> LocalText<'a> {
    /// Make a new localizable text placeholder for a Fluent key with no args
    pub fn new(key: &str) -> LocalText {
        LocalText {
            key: String::from(key),
            args: None,
        }
    }

    /// Add values for variables to be passed as arguments to Fluent
    pub fn arg(self, var: &'a str, val: impl ToString) -> LocalText<'a> {
        let value = FluentValue::from(val.to_string());
        let args: Option<FluentArgs<'a>> = match self.args {
            Some(mut args) => {
                args.set(var, value);
                Some(args)
            }
            None => {
                let mut args: FluentArgs<'a> = FluentArgs::new();
                args.set(var, value);
                Some(args)
            }
        };
        LocalText {
            key: String::from(&self.key),
            args,
        }
    }

    /// Format and return a string for the given key and args using the preferred locale fallback
    /// stack as negotiated at runtime.
    pub fn fmt(&self) -> String {
        let locales = LOCALES
            .read()
            .expect("Unable to read negotiated locale list")
            .clone();
        let bundled_resources = EmbeddedBundleManager {};
        let scan_resources: Vec<ResourceId> = FTL_RESOURCES
            .iter()
            .map(|s| ResourceId::new(s.to_string(), ResourceType::Required))
            .collect();
        let loc = Localization::with_env(scan_resources, true, locales, bundled_resources);
        let bundles = loc.bundles();
        let mut errors = vec![];
        let value = bundles
            .format_value_sync(&self.key, self.args.as_ref(), &mut errors)
            .expect("Failed to format a value");
        value.unwrap_or(Cow::from("")).to_string()
    }
}

pub struct BundleIter {
    locales: <Vec<LanguageIdentifier> as IntoIterator>::IntoIter,
    res_ids: FxHashSet<ResourceId>,
}

impl Iterator for BundleIter {
    type Item = FluentBundleResult<FluentResource>;

    fn next(&mut self) -> Option<Self::Item> {
        let locale = self.locales.next()?;
        let mut bundle = FluentBundle::new(vec![locale.clone()]);
        let mut res_path_scheme = PathBuf::new();
        res_path_scheme.push("{locale}");
        res_path_scheme.push("{res_id}");
        for res_id in self.res_ids.iter() {
            let res_path_scheme = res_path_scheme
                .to_str()
                .expect("Locale resource path not valid");
            let res_path = res_path_scheme.replace("{locale}", &locale.to_string());
            let res_id = res_id.to_string();
            let path = res_path.replace("{res_id}", res_id.as_str());
            if let Some(source) = Asset::get(&path) {
                let data = str::from_utf8(source.data.as_ref())
                    .expect("Fluent data source not valid UTF-8");
                let res = FluentResource::try_new(data.to_string())
                    .expect("Fluent data source not valid resource");
                bundle
                    .add_resource(res)
                    .expect("Unable to add Fluent resource to bundle");
            }
        }
        Some(Ok(bundle))
    }
}

impl Stream for BundleIter {
    type Item = FluentBundleResult<FluentResource>;

    fn poll_next(
        self: std::pin::Pin<&mut Self>,
        _cx: &mut std::task::Context<'_>,
    ) -> std::task::Poll<Option<Self::Item>> {
        unimplemented!()
    }
}

struct EmbeddedBundleManager {}

impl BundleGenerator for EmbeddedBundleManager {
    type Resource = FluentResource;
    type LocalesIter = IntoIter<LanguageIdentifier>;
    type Iter = BundleIter;
    type Stream = BundleIter;

    fn bundles_iter(
        &self,
        locales: Self::LocalesIter,
        res_ids: FxHashSet<ResourceId>,
    ) -> Self::Iter {
        BundleIter { locales, res_ids }
    }

    fn bundles_stream(
        &self,
        _locales: Self::LocalesIter,
        _res_ids: FxHashSet<ResourceId>,
    ) -> Self::Stream {
        unimplemented!();
    }
}

/// Strip off any potential system locale encoding on the end of LC_LANG
pub fn normalize_lang(input: &str) -> String {
    let re = Regex::new(r"\..*$").unwrap();
    re.replace(input, "").to_string()
}

/// Scan our embedded assets for what recognizable locale data we have on hand
// https://github.com/projectfluent/fluent-rs/blob/c9e45651/fluent-resmgr/examples/simple-resmgr.rs#L35
pub fn list_available_locales() -> Locales {
    let mut embedded = vec![];
    for asset in Asset::iter() {
        let asset_name = asset.to_string();
        let mut components = Path::new(&asset_name).components();
        if let Some(Component::Normal(part)) = components.next() {
            let bytes = part
                .to_str()
                .expect("Cannot handle directory name in assets")
                .as_bytes();
            // if let Ok(langid) = LanguageIdentifier::try_from_bytes(bytes) {
            if let Ok(langid) = LanguageIdentifier::from_bytes(bytes) {
                if let Some(Component::Normal(part)) = components.next() {
                    if self::FTL_RESOURCES
                        .iter()
                        .any(|v| v == &part.to_str().unwrap())
                    {
                        embedded.push(langid);
                    }
                }
            }
        }
    }
    embedded.dedup();
    Locales(embedded)
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn trim_systemd_locale() {
        let out = normalize_lang(&String::from("en_US.utf8"));
        assert_eq!(out, String::from("en_US"));
    }

    #[test]
    fn parse_locale() {
        let out = &accepted_languages::parse("tr_tr")[0];
        let tr: LanguageIdentifier = "tr-TR".parse().unwrap();
        assert_eq!(out.to_string(), tr.to_string());
    }
}
