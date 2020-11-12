use crate::setup;
use crate::CONFIG;
use git2::{DescribeFormatOptions, DescribeOptions};
use regex::Regex;
use std::{env, path};

use crate::Result;

// FTL: help-subcommand-status
/// Show status information about setup, configuration, and build state
pub fn run() -> Result<()> {
    crate::header("status-header");
    CONFIG.set_bool("verbose", true)?;
    setup::is_setup()?;
    Ok(())
}

#[allow(dead_code)]
#[derive(Debug)]
enum RunAsMode {
    RunAsSubmodule,
    RunAsDirectory,
    RunAsDocker,
    RunAsRunner,
    RunAsSystem,
}

#[allow(dead_code)]
/// Determine the runtime mode
fn run_as() -> RunAsMode {
    RunAsMode::RunAsDocker {}
}

/// Check to see if we're running in GitHub Actions
pub fn is_gha() -> Result<bool> {
    let ret = match env::var("GITHUB_ACTIONS") {
        Ok(_) => true,
        Err(_) => false,
    };
    crate::display_check("status-is-gha", ret);
    Ok(ret)
}

/// Figure out if we're running inside Docker or another container
pub fn is_container() -> bool {
    let dockerenv = path::Path::new("/.dockerenv");
    dockerenv.exists()
}

pub fn get_gitname() -> Result<String> {
    fn origin() -> Result<String> {
        let repo = crate::get_repo()?;
        let remote = repo.find_remote("origin")?;
        let url = remote.url().unwrap();
        let re = Regex::new(r"^(.*/)([^/]+)(/?\.git/?)$").unwrap();
        let name = re
            .captures(url)
            .ok_or(crate::Error::new("error-no-remote"))?
            .get(2)
            .ok_or(crate::Error::new("error-no-remote"))?
            .as_str();
        Ok(String::from(name))
    }
    fn path() -> Result<String> {
        let path = &CONFIG.get_string("path")?;
        let file = path::Path::new(path)
            .file_name()
            .ok_or(crate::Error::new("error-no-path"))?
            .to_str();
        Ok(file.unwrap().to_string())
    }
    let default = Ok(String::from("fontship"));
    origin().or(path().or(default))
}

/// Scan for existing makefiles with Fontship rules
pub fn get_rules() -> Result<Vec<path::PathBuf>> {
    let repo = crate::get_repo()?;
    let root = repo.workdir().unwrap();
    let files = vec!["GNUMakefile", "makefile", "Makefile", "rules.mk"];
    let mut rules = Vec::new();
    for file in &files {
        let p = root.join(file);
        if p.exists() {
            rules.push(p);
        }
    }
    Ok(rules)
}

/// Scan for sources
pub fn get_sources() -> Result<Vec<path::PathBuf>> {
    let repo = crate::get_repo()?;
    let index = repo.index()?;
    let mut sources = vec![];
    let sourcedir = CONFIG.get_string("sourcedir")?;
    let sourcedir = path::Path::new(&sourcedir);
    let sourceexts = Regex::new(r"\.(sfd|glyphs|designspace)$").unwrap();
    let ufoexts = Regex::new(r"\.ufo$").unwrap();
    for entry in index.iter() {
        let rawpath = &entry.path;
        let path = crate::bytes2path(rawpath);
        if !path.exists() {
            continue;
        }
        if let Ok(part) = path.strip_prefix(&sourcedir) {
            let mut components = part.components();
            if let Some(path::Component::Normal(name)) = components.next() {
                let n = name.to_str().unwrap().clone();
                if let Some(_) = sourceexts.find(n) {
                    sources.push(path.to_path_buf());
                } else if let Some(_) = ufoexts.find(n) {
                    let mut p = sourcedir.to_path_buf();
                    p.push(name);
                    sources.push(p);
                }
            }
        }
    }
    sources.dedup();
    Ok(sources)
}

/// Figure out version string from repo tags
pub fn get_git_version() -> String {
    let zero_version = String::from("0.000");
    let repo = crate::get_repo().unwrap();
    let mut opts = DescribeOptions::new();
    opts.describe_tags().pattern("*[0-9].[0-9][0-9][0-9]");
    let desc = match repo.describe(&opts) {
        Ok(a) => {
            let mut fmt = DescribeFormatOptions::new();
            fmt.always_use_long_format(true);
            a.format(Some(&fmt)).unwrap()
        }
        Err(_) => {
            let head = repo.revparse("HEAD").unwrap();
            let mut revwalk = repo.revwalk().unwrap();
            revwalk.push_head().unwrap();
            let ahead = revwalk.count();
            let sha = head.from().unwrap().short_id().unwrap();
            format!("{}-{}-g{}", zero_version, ahead, sha.as_str().unwrap())
        }
    };
    let prefix = Regex::new(r"^v").unwrap();
    let sep = Regex::new(r"-").unwrap();
    String::from(sep.replace(&prefix.replace(desc.as_str(), ""), "-r"))
}
