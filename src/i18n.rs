use crate::*;

#[derive(Debug)]
pub struct FluentArgs {}

impl FluentArgs {
    pub fn new() -> FluentArgs {
        FluentArgs {}
    }
}

/// A Fluent key plus any variables that will be needed to format it.
#[derive(Debug)]
pub struct LocalText {
    key: String,
    args: Option<FluentArgs>,
}

impl LocalText {
    /// Make a new localizable text placeholder for a Fluent key with no args
    pub fn new(key: &str) -> LocalText {
        LocalText {
            key: String::from(key),
            args: None,
        }
    }

    /// Add values for variables to be passed as arguments to Fluent
    pub fn arg(self, var: &str, val: impl ToString) -> LocalText {
        let args: Option<FluentArgs> = None;
        LocalText {
            key: String::from(&self.key),
            args: args,
        }
    }

    /// Format and return a string for the given key and args using the prefered locale fallback
    /// stack as negotiated at runtime.
    pub fn fmt(&self) -> String {
        String::from("foo")
    }
}
