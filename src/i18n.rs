use crate::*;

use fluent_templates::{fluent_bundle::FluentValue, ArcLoader, Loader};
use std::collections::HashMap;
use unic_langid::{langid, LanguageIdentifier};

lazy_static! {
    pub static ref LOCALES: ArcLoader =
        ArcLoader::builder("assets/", unic_langid::langid!("en-US"))
            .build()
            .unwrap();
}

#[derive(Debug)]
pub struct FluentArgs {}

impl FluentArgs {
    pub fn new() -> FluentArgs {
        FluentArgs {}
    }
}

/// A Fluent key plus any variables that will be needed to format it.
#[derive(Debug)]
pub struct LocalText<'a> {
    key: String,
    args: Option<&'a HashMap<String, FluentValue<'a>>>,
}

const EN: LanguageIdentifier = langid!("en-US");

impl<'a> LocalText<'a> {
    /// Make a new localizable text placeholder for a Fluent key with no args
    pub fn new(key: &str) -> LocalText {
        LocalText {
            key: String::from(key),
            args: None,
        }
    }

    /// Add values for variables to be passed as arguments to Fluent
    pub fn arg(self, var: &str, val: impl ToString) -> LocalText {
        let va = FluentValue::String(val.into());
        let args = {
            let mut map = HashMap::new();
            map.insert(String::from(var), va);
            map
        };
        LocalText {
            key: String::from(&self.key),
            args: Some(&args),
        }
    }

    /// Format and return a string for the given key and args using the prefered locale fallback
    /// stack as negotiated at runtime.
    pub fn fmt(&self) -> String {
        // let lang = CONF.get_string("language").expect("Unable to retrieve language from config")
        // .lookup_single_language(&EN, &self.key, None)
        LOCALES.lookup_complete(&EN, &self.key, self.args)
    }
}
