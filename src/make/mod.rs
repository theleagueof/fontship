use crate::i18n::LocalText;
use crate::*;

use colored::Colorize;
use itertools::Itertools;
use regex::Regex;
use std::io::prelude::*;
use std::{ffi::OsString, io};
use subprocess::{Exec, ExitStatus, Redirection};

// FTL: help-subcommand-make
/// Build specified target(s)
pub fn run(target: Vec<String>) -> Result<()> {
    setup::is_setup()?;
    show_header("make-header");
    let mut makeflags: Vec<OsString> = Vec::new();
    let cpus = num_cpus::get();
    makeflags.push(OsString::from(format!("--jobs={}", cpus)));
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
    let mut process = Exec::cmd("make")
        .args(&makeflags)
        .args(&makefiles)
        .args(&target);
    // Start deprecating non-CLI usage
    let gitname = status::get_gitname()?;
    let sources = status::get_sources()?;
    let sources_str = format!(
        "{}",
        sources
            .iter()
            .format_with(" ", |p, f| f(&p.to_str().unwrap()))
    );
    let git_version = status::get_git_version();
    let font_version = format_font_version(git_version.clone());
    process = process
        .env("FONTSHIP_CLI", "true")
        .env("FONTSHIPDIR", CONFIGURE_DATADIR)
        .env("CONTAINERIZED", status::is_container().to_string())
        .env("GITNAME", &gitname)
        .env("PROJECT", pname(&gitname))
        .env("PROJECTDIR", CONF.get_string("path")?)
        .env("GitVersion", git_version)
        .env("FontVersion", font_version)
        .env("SOURCEDIR", CONF.get_string("sourcedir")?)
        .env("SOURCES", sources_str);
    if CONF.get_bool("debug")? {
        process = process.env("DEBUG", "true");
    };
    if CONF.get_bool("quiet")? {
        process = process.env("QUIET", "true");
    };
    if CONF.get_bool("verbose")? {
        process = process.env("VERBOSE", "true");
    };
    let repo = get_repo()?;
    let workdir = repo.workdir().unwrap();
    process = process.cwd(workdir);
    let process = process.stderr(Redirection::Merge).stdout(Redirection::Pipe);
    let mut popen = process.popen()?;
    let buf = io::BufReader::new(popen.stdout.as_mut().unwrap());
    let mut backlog: Vec<String> = Vec::new();
    let seps = Regex::new(r"").unwrap();
    let mut ret: u32 = 0;
    for line in buf.lines() {
        let text: &str = &line.unwrap();
        let fields: Vec<&str> = seps.splitn(text, 4).collect();
        match fields[0] {
            "FONTSHIP" => match fields[1] {
                "PRE" => report_start(fields[2]),
                "STDOUT" => {
                    if fields[2] == "_gha" {
                        println!("{}", fields[3]);
                    } else if CONF.get_bool("verbose")? {
                        report_line(fields[3]);
                    } else {
                        backlog.push(String::from(fields[3]));
                    }
                }
                "STDERR" => {
                    if CONF.get_bool("verbose")? {
                        report_line(fields[3]);
                    } else {
                        backlog.push(String::from(fields[3]));
                    }
                }
                "POST" => match fields[2] {
                    "0" => {
                        report_end(fields[3]);
                    }
                    val => {
                        report_fail(fields[3]);
                        ret = val.parse().unwrap_or(1);
                    }
                },
                _ => {
                    let errmsg = LocalText::new("make-error-unknown-code").fmt();
                    panic!(errmsg)
                }
            },
            _ => backlog.push(String::from(fields[0])),
        }
    }
    let status = popen.wait();
    match status {
        Ok(ExitStatus::Exited(int)) => {
            let foo = int + ret;
            match foo {
                0 => Ok(()),
                1 => {
                    dump_backlog(&backlog);
                    Err(Box::new(io::Error::new(
                        io::ErrorKind::InvalidInput,
                        LocalText::new("make-error-unfinished").fmt(),
                    )))
                }
                2 => {
                    dump_backlog(&backlog);
                    Err(Box::new(io::Error::new(
                        io::ErrorKind::InvalidInput,
                        LocalText::new("make-error-build").fmt(),
                    )))
                }
                3 => {
                    if !CONF.get_bool("verbose")? {
                        dump_backlog(&backlog);
                    }
                    Err(Box::new(io::Error::new(
                        io::ErrorKind::InvalidInput,
                        LocalText::new("make-error-target").fmt(),
                    )))
                }
                _ => {
                    dump_backlog(&backlog);
                    Err(Box::new(io::Error::new(
                        io::ErrorKind::InvalidInput,
                        LocalText::new("make-error-unknown").fmt(),
                    )))
                }
            }
        }
        _ => Err(Box::new(io::Error::new(
            io::ErrorKind::InvalidInput,
            LocalText::new("make-error").fmt(),
        ))),
    }
}

fn dump_backlog(backlog: &Vec<String>) {
    let start = LocalText::new("make-backlog-start").fmt();
    eprintln!("{} {}", "┖┄".cyan(), start);
    for line in backlog.iter() {
        eprintln!("{}", line);
    }
    let end = LocalText::new("make-backlog-end").fmt();
    eprintln!("{} {}", "┎┄".cyan(), end);
}

fn report_line(line: &str) {
    eprintln!("{} {}", "┠╎".cyan(), line.dimmed());
}

fn report_start(target: &str) {
    let text = LocalText::new("make-report-start")
        .arg("target", target.white().bold())
        .fmt();
    eprintln!("{} {}", "┠┄".cyan(), text.yellow());
}

fn report_end(target: &str) {
    let text = LocalText::new("make-report-end")
        .arg("target", target.white().bold())
        .fmt();
    eprintln!("{} {}", "┠┄".cyan(), text.green());
}

fn report_fail(target: &str) {
    let text = LocalText::new("make-report-fail")
        .arg("target", target.white().bold())
        .fmt();
    eprintln!("{} {}", "┠┄".cyan(), text.red());
}
