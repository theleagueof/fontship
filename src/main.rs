use clap::{FromArgMatches, IntoApp};
use fontship::cli::{Cli, Subcommand};
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
    let invocation: Vec<String> = env::args().collect();
    let ret = if status::is_gha()? && invocation.len() == 1 {
        CONF.set_str("language", "en-US")?;
        fontship::show_welcome();
        let target = vec![String::from("_gha"), String::from("dist")];
        make::run(target)
    } else {
        let app = Cli::into_app().version(VERSION);
        let matches = app.get_matches();
        let args = Cli::from_arg_matches(&matches);
        CONF.from_args(&args)?;
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
