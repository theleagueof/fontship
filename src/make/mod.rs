use crate::CONFIG;
use crate::{status, CONFIGURE_DATADIR};
use regex::Regex;
use std::io::prelude::*;
use std::{error, ffi::OsString, io, result};
use subprocess::{Exec, Redirection};

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
    process = process.cwd(workdir);
    let out = process.stderr(Redirection::Merge).stream_stdout()?;
    let buf = io::BufReader::new(out);
    let mut backlog: Vec<String> = Vec::new();
    // let re = Regex::new(r"FONTSHIP (\k+").unwrap();
    let seps = Regex::new(r"").unwrap();
    for line in buf.lines() {
        let text: &str = &line.unwrap();
        // eprintln!("foo—{}", String::from(text));
        // backlog.push(String::from(text));
        let fields: Vec<&str> = seps.splitn(text, 4).collect();
        match fields[0] {
            "FONTSHIP" => match fields[1] {
                "START" => crate::show_start(fields[2]),
                "LINES" => {
                    backlog.push(String::from(fields[2]));
                }
                "END" => match fields[2] {
                    "0" => crate::show_end(fields[3]),
                    _ => crate::show_err(fields[3]),
                },
                _ => panic!("Fontship's make returned an unknown action code!"),
            },
            _ => backlog.push(String::from(fields[0])),
        }
    }
    Ok(())
}
