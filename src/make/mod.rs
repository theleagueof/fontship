use crate::CONFIG;
use crate::{status, CONFIGURE_DATADIR};
use std::{error, ffi::OsString, result};
use subprocess::Exec;

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
    process.join()?;
    Ok(())
}
