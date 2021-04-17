use crate::*;

use fluent::{FluentArgs, FluentBundle, FluentResource, FluentValue};
use fluent_fallback::Localization;
use regex::Regex;
use rust_embed::RustEmbed;
use std::{iter, ops, path, str, sync, vec};
use unic_langid::LanguageIdentifier;

// List of Fluent resource filenames to scan for keys from each locale directory.
static FTL_RESOURCES: &[&str] = &["cli.ftl"];

/// Embed everything in the assets folder directly into the binary
#[derive(RustEmbed)]
#[folder = "assets/"]
pub struct Asset;

lazy_static! {
    /// List of Locales in order of closeness to the runtime config
    pub static ref LOCALES: sync::RwLock<Locales> =
        sync::RwLock::new(Locales::new(CONF.get_string("language").expect("Unable to retrieve language from config")));
}

/// A prioritized locale fallback stack
#[derive(Debug)]
pub struct Locales(Vec<LanguageIdentifier>);

impl ops::Deref for Locales {
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
        let requested = fluent_langneg::accepted_languages::parse(&language);
        let default: LanguageIdentifier = DEFAULT_LOCALE
            .parse()
            .expect("Unable to parse default locale");
        Locales(
            fluent_langneg::negotiate_languages(
                &requested,
                &available,
                Some(&default),
                fluent_langneg::NegotiationStrategy::Filtering,
            )
            .iter()
            .copied()
            .cloned()
            .collect(),
        )
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
                args.insert(var, value);
                Some(args)
            }
            None => {
                let mut args: FluentArgs<'a> = FluentArgs::new();
                args.insert(var, value);
                Some(args)
            }
        };
        LocalText {
            key: String::from(&self.key),
            args,
        }
    }

    /// Format and return a string for the given key and args using the prefered locale fallback
    /// stack as negotiated at runtime.
    pub fn fmt(&self) -> String {
        let locales = LOCALES
            .read()
            .expect("Unable to read negotiated locale list");
        let mut res_path_scheme = path::PathBuf::new();
        res_path_scheme.push("{locale}");
        res_path_scheme.push("{res_id}");
        let generate_messages = |res_ids: &[String]| {
            let mut resolved_locales = locales.iter();
            let res_path_scheme = res_path_scheme
                .to_str()
                .expect("Locale resource path not valid");
            let res_ids = res_ids.to_vec();
            iter::from_fn(move || {
                resolved_locales.next().map(|locale| {
                    let x = vec![locale.clone()];
                    let mut bundle = FluentBundle::new(&x);
                    let res_path = res_path_scheme.replace("{locale}", &locale.to_string());
                    for res_id in &res_ids {
                        let path = res_path.replace("{res_id}", res_id);
                        if let Some(source) = Asset::get(&path) {
                            let data = str::from_utf8(source.as_ref())
                                .expect("Fluent data source not valid UTF-8");
                            let res = FluentResource::try_new(data.to_string())
                                .expect("Fluent data source not valid resource");
                            bundle
                                .add_resource(res)
                                .expect("Unable to add Fluent resource to bundle");
                        }
                    }
                    bundle
                })
            })
        };
        let loc = Localization::new(
            FTL_RESOURCES.iter().map(|s| s.to_string()).collect(),
            generate_messages,
        );
        // let value: String = loc.format_value(&self.key, &self.args).to_string();
        let value: String = loc.format_value(&self.key, self.args.as_ref()).to_string();
        value
    }
}

/// Strip off any potential system locale encoding on the end of LC_LANG
pub fn normalize_lang(input: &str) -> String {
    let re = Regex::new(r"\..*$").unwrap();
    re.replace(&input, "").to_string()
}

/// Scan our embedded assets for what recognisable locale data we have on hand
// https://github.com/projectfluent/fluent-rs/blob/c9e45651/fluent-resmgr/examples/simple-resmgr.rs#L35
pub fn list_available_locales() -> Locales {
    let mut embeded = vec![];
    for asset in Asset::iter() {
        let asset_name = asset.to_string();
        let path = path::Path::new(&asset_name);
        let mut components = path.components();
        if let Some(path::Component::Normal(part)) = components.next() {
            let bytes = part
                .to_str()
                .expect("Cannot handle directory name in assets")
                .as_bytes();
            if let Ok(langid) = LanguageIdentifier::from_bytes(bytes) {
                if let Some(path::Component::Normal(part)) = components.next() {
                    if self::FTL_RESOURCES
                        .iter()
                        .any(|v| v == &part.to_str().unwrap())
                    {
                        embeded.push(langid);
                    }
                }
            }
        }
    }
    embeded.dedup();
    Locales(embeded)
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
        let out = &fluent_langneg::accepted_languages::parse("tr_tr")[0];
        let tr: LanguageIdentifier = "tr-TR".parse().unwrap();
        assert_eq!(out.to_string(), tr.to_string());
    }
}
