use clap::{FromArgMatches, IntoApp};
use fontship::cli::{Cli, Subcommand};
use fontship::config::CONFIG;
use fontship::VERSION;
use fontship::{make, setup, status};
use std::{env, error};

fn main() -> Result<(), Box<dyn error::Error>> {
    CONFIG.defaults()?;
    CONFIG.from_env()?;
    // Workaround for Github Actions usage to make the prebuilt Docker image
    // invocation interchangeable with the default run-time built invocation we
    // need to set some default arguments. These are not used by the regular CLI.
    // See the action.yml file for matching arguments for run-time invocations.
    let invocation: Vec<String> = env::args().collect();
    let ret = if status::is_gha()? && invocation.len() == 1 {
        CONFIG.set_str("language", "en-US")?;
        fontship::show_welcome();
        let target = vec![String::from("_gha"), String::from("dist")];
        make::run(target)
    } else {
        let app = Cli::into_app().version(VERSION);
        let matches = app.get_matches();
        let args = Cli::from_arg_matches(&matches);
        CONFIG.from_args(&args)?;
        fontship::show_welcome();
        match args.subcommand {
            Subcommand::Make { target } => make::run(target),
            Subcommand::Setup {} => setup::run(),
            Subcommand::Status {} => status::run(),
        }
    };
    fontship::show_outro();
    return ret;
}
