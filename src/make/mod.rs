use crate::CONFIG;
use crate::{status, CONFIGURE_DATADIR};
// use nix::{sys, unistd};
use std::io::prelude::*;
use std::{error, ffi::OsString, io, result};
use subprocess::{Exec, Redirection};
// use tempfile::Builder;

type Result<T> = result::Result<T, Box<dyn error::Error>>;

// FTL: help-subcommand-make
/// Build specified target(s)
pub fn run(target: Vec<String>) -> Result<()> {
    crate::header("make-header");
    let mut makefiles: Vec<OsString> = Vec::new();
    makefiles.push(OsString::from("-f"));
    makefiles.push(OsString::from(format!(
        "{}{}",
        CONFIGURE_DATADIR, "rules/fontship.mk"
    )));
    let rules = status::get_rules()?;
    for rule in rules {
        makefiles.push(OsString::from("-f"));
        let p = rule.into_os_string();
        makefiles.push(p);
    }
    makefiles.push(OsString::from("-f"));
    makefiles.push(OsString::from(format!(
        "{}{}",
        CONFIGURE_DATADIR, "rules/rules.mk"
    )));
    let mut process = Exec::cmd("make").args(&makefiles).args(&target);
    if CONFIG.get_bool("debug")? {
        process = process.env("DEBUG", "true");
    };
    if CONFIG.get_bool("quiet")? {
        process = process.env("QUIET", "true");
    };
    if CONFIG.get_bool("verbose")? {
        process = process.env("VERBOSE", "true");
    };
    let repo = status::get_repo()?;
    let workdir = repo.workdir().unwrap();
    // let fifo_dir = Builder::new()
    //     .prefix("fontship-")
    //     .suffix(".fifo")
    //     .rand_bytes(5)
    //     .tempdir()?;
    // let fifo_path = fifo_dir.path().join("pid");
    // unistd::mkfifo(&fifo_path, sys::stat::Mode::S_IRWXU)?;
    // process = process.cwd(workdir).env("FONTSHIP_FIFO", fifo_path);
    process = process.cwd(workdir);

    // let stdout = process.capture()?.stdout_str();
    // eprintln!("STDOUT was {}", stdout.len());

    let out = process.stderr(Redirection::Merge).stream_stdout()?;
    let buf = io::BufReader::new(out);
    for line in buf.lines() {
        crate::show_line(line.unwrap());
    }

    // process.join()?;
    Ok(())
}
