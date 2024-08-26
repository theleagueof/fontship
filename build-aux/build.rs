use clap::IntoApp;
use clap_complete::generator::generate_to;
use clap_complete::shells::{Bash, Elvish, Fish, PowerShell, Zsh};
use std::{collections, env, fs};
use vergen::{vergen, Config};

include!("../src/cli.rs");

fn main() {
    let mut flags = Config::default();
    // If passed a version, use that instead of vergen's formatting
    if let Ok(val) = env::var("FONTSHIP_VERSION") {
        *flags.git_mut().enabled_mut() = false;
        println!("cargo:rustc-env=VERGEN_GIT_SEMVER={}", val)
    };
    vergen(flags).expect("Unable to generate the cargo keys!");
    pass_on_configure_details();
    generate_shell_completions();
}

/// Generate shell completion files from CLI interface
fn generate_shell_completions() {
    let out_dir = match env::var_os("OUT_DIR") {
        None => return,
        Some(out_dir) => out_dir,
    };
    let completions_dir = path::Path::new(&out_dir).join("completions");
    fs::create_dir_all(&completions_dir)
        .expect("Could not create directory in which to place completions");
    let app = Cli::command();
    let bin_name: &str = app
        .get_bin_name()
        .expect("Could not retrieve bin-name from generated Clap app");
    let mut app = Cli::command();
    generate_to(Bash, &mut app, bin_name, &completions_dir)
        .expect("Unable to generate bash completions");
    generate_to(Elvish, &mut app, bin_name, &completions_dir)
        .expect("Unable to generate elvish completions");
    generate_to(Fish, &mut app, bin_name, &completions_dir)
        .expect("Unable to generate fish completions");
    generate_to(PowerShell, &mut app, bin_name, &completions_dir)
        .expect("Unable to generate powershell completions");
    generate_to(Zsh, &mut app, bin_name, &completions_dir)
        .expect("Unable to generate zsh completions");
}

/// Pass through some variables set by autoconf/automake about where we're installed to cargo for
/// use in finding resources at runtime
fn pass_on_configure_details() {
    let mut autoconf_vars = collections::HashMap::new();
    autoconf_vars.insert("CONFIGURE_PREFIX", String::from("./"));
    autoconf_vars.insert("CONFIGURE_BINDIR", String::from("./"));
    autoconf_vars.insert("CONFIGURE_DATADIR", String::from("./"));
    for (var, default) in autoconf_vars {
        let val = env::var(var).unwrap_or(default);
        println!("cargo:rustc-env={}={}", var, val);
    }
}
