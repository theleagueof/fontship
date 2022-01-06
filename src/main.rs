use clap::{FromArgMatches, IntoApp};

use fontship::cli::{Cli, Commands};
use fontship::config::CONF;
use fontship::{make, setup, status};
use fontship::{Result, VERSION};

use std::env;

fn main() -> Result<()> {
    CONF.defaults()?;
    CONF.from_env()?;
    // Workaround for Github Actions usage to make the prebuilt Docker image
    // invocation interchangeable with the default run-time built invocation we
    // need to set some default arguments. These are not used by the regular CLI.
    // See the action.yml file for matching arguments for run-time invocations.
    let ret = if status::is_gha()? && env::args().count() == 1 {
        CONF.set_str("language", "en-US")?;
        fontship::show_welcome();
        let target = vec![String::from("_gha"), String::from("dist")];
        make::run(target)
    } else {
        let app = Cli::into_app().version(VERSION);
        let matches = app.get_matches();
        let args = Cli::from_arg_matches(&matches)?;
        CONF.from_args(&args)?;
        fontship::show_welcome();
        match args.subcommand {
            Commands::Make { target } => make::run(target),
            Commands::Setup {} => setup::run(),
            Commands::Status {} => status::run(),
        }
    };
    fontship::show_outro();
    ret
}
