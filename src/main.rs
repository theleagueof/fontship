use clap::{FromArgMatches, IntoApp};
use fontship::cli::Cli;
use std::error;

fn main() -> Result<(), Box<dyn error::Error>> {
    let app = Cli::into_app();
    let matches = app.get_matches();
    let _args = Cli::from_arg_matches(&matches);
    Ok(())
}
