use clap::Command;
use clap_complete::generator::generate_to;
use clap_complete::shells::{Bash, Elvish, Fish, PowerShell, Zsh};
use clap_mangen::Man;
use std::{collections, env, fs};
use vergen::EmitBuilder;

include!("../src/cli.rs");

fn main() {
    if let Ok(val) = env::var("AUTOTOOLS_DEPENDENCIES") {
        for dependency in val.split(' ') {
            println!("cargo:rerun-if-changed={dependency}");
        }
    }
    let mut builder = EmitBuilder::builder();
    // If passed a version from automake, use that instead of vergen's formatting
    if let Ok(val) = env::var("VERSION_FROM_AUTOTOOLS") {
        println!("cargo:rustc-env=VERGEN_GIT_DESCRIBE={val}")
    } else {
        builder = *builder.git_describe(true, true, None);
    };
    builder.emit().expect("Unable to generate the cargo keys!");
    pass_on_configure_details();
    generate_manpage();
    generate_shell_completions();
}

/// Generate man page
fn generate_manpage() {
    let out_dir = match env::var_os("OUT_DIR") {
        None => return,
        Some(out_dir) => out_dir,
    };
    let manpage_dir = path::Path::new(&out_dir);
    fs::create_dir_all(manpage_dir).expect("Unable to create directory for generated manpages");
    let bin_name: &str = "fontship";
    let cli = Command::new("fontship");
    let cli = Cli::augment_args(cli);
    let man = Man::new(cli);
    let mut buffer: Vec<u8> = Default::default();
    man.render(&mut buffer)
        .expect("Unable to render man page to UTF-8 string");
    fs::write(manpage_dir.join(format!("{bin_name}.1")), buffer)
        .expect("Unable to write manepage to file");
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
    let bin_name: &str = "fontship";
    let cli = Command::new("fontship");
    let mut cli = Cli::augment_args(cli);
    generate_to(Bash, &mut cli, bin_name, &completions_dir)
        .expect("Unable to generate bash completions");
    generate_to(Elvish, &mut cli, bin_name, &completions_dir)
        .expect("Unable to generate elvish completions");
    generate_to(Fish, &mut cli, bin_name, &completions_dir)
        .expect("Unable to generate fish completions");
    generate_to(PowerShell, &mut cli, bin_name, &completions_dir)
        .expect("Unable to generate powershell completions");
    generate_to(Zsh, &mut cli, bin_name, &completions_dir)
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
        println!("cargo:rustc-env={var}={val}");
    }
}
