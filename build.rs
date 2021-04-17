extern crate vergen;

use clap::IntoApp;
use clap_generate::{generate_to, generators};
use std::{collections, env, fs};
use vergen::{generate_cargo_keys, ConstantsFlags};

include!("src/cli.rs");

fn main() {
    // Setup the flags, toggling off the 'SEMVER_FROM_CARGO_PKG' flag
    let mut flags = ConstantsFlags::all();
    flags.toggle(ConstantsFlags::SEMVER_FROM_CARGO_PKG);

    // Generate the 'cargo:' key output
    generate_cargo_keys(flags).expect("Unable to generate the cargo keys!");

    // If automake has passed a version, use that instead of vergen's formatting
    if let Ok(val) = env::var("FONTSHIP_VERSION") {
        println!("cargo:rustc-env=VERGEN_SEMVER_LIGHTWEIGHT={}", val)
    };

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
    let app = Cli::into_app();
    let bin_name: &str = app
        .get_bin_name()
        .expect("Could not retrieve bin-name from generated Clap app");
    let mut app = Cli::into_app();
    generate_to::<generators::Bash, _, _>(&mut app, bin_name, &completions_dir);
    generate_to::<generators::Elvish, _, _>(&mut app, bin_name, &completions_dir);
    generate_to::<generators::Fish, _, _>(&mut app, bin_name, &completions_dir);
    generate_to::<generators::PowerShell, _, _>(&mut app, bin_name, &completions_dir);
    generate_to::<generators::Zsh, _, _>(&mut app, bin_name, &completions_dir);
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
