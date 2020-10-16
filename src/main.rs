use clap::{FromArgMatches, IntoApp};
use fontship::cli::{Cli, Subcommand};
use fontship::VERSION;
use fontship::{make, setup, status};
use std::error;

fn main() -> Result<(), Box<dyn error::Error>> {
    let app = Cli::into_app().version(VERSION);
    let matches = app.get_matches();
    let args = Cli::from_arg_matches(&matches);
    match args.subcommand {
        Subcommand::Make { target } => make::run(target),
        Subcommand::Setup {} => setup::run(),
        Subcommand::Status { path } => status::run(path),
    }
}
