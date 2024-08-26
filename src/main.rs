use clap::{Args, Command, FromArgMatches as _};

use fontship::cli::{Cli, Commands};
use fontship::config::CONF;
use fontship::ui::{UserInterface, FONTSHIPUI};
use fontship::{make, setup, status};
use fontship::{Result, VERSION};

fn main() -> Result<()> {
    CONF.defaults()?;
    CONF.merge_env()?;
    let cli = Command::new("fontship").version(*VERSION);
    let cli = Cli::augment_args(cli);
    let matches = cli.get_matches();
    let args = Cli::from_arg_matches(&matches).expect("Unable to parse arguments");
    CONF.merge_args(&args)?;
    FONTSHIPUI.welcome();
    let subcommand = Commands::from_arg_matches(&matches)?;
    let ret = match subcommand {
        Commands::Make { target } => make::run(target),
        Commands::Setup {} => setup::run(),
        Commands::Status {} => status::run(),
    };
    FONTSHIPUI.farewell();
    ret
}
