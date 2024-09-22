// SPDX-FileCopyrightText: © 2020 Caleb Maclennan <caleb@alerque.com>
// SPDX-License-Identifier: GPL-3.0-only

use crate::i18n::LocalText;
use crate::ui_ascii::AsciiInterface;
use crate::ui_indicatif::IndicatifInterface;
use crate::VERSION;
use crate::*;

use console::user_attended;
use std::collections::HashMap;
use std::str;
use std::sync::Arc;
use std::sync::RwLock;

static ERROR_UI_WRITE: &str = "Unable to gain write lock on ui status wrapper";

lazy_static! {
    #[derive(Debug)]
    pub static ref FONTSHIPUI: RwLock<Box<dyn UserInterface>> = RwLock::new(UISwitcher::pick());
}

pub type JobMap = HashMap<MakeTarget, Box<dyn JobStatus>>;

#[derive(Debug, Clone, Default, Eq, Hash, PartialEq)]
pub struct MakeTarget {
    target: String,
}

impl MakeTarget {
    pub fn new(target: &String) -> Self {
        Self {
            target: target.to_string(),
        }
    }
}

impl std::ops::Deref for MakeTarget {
    type Target = String;
    fn deref(&self) -> &Self::Target {
        &self.target
    }
}

impl fmt::Display for MakeTarget {
    fn fmt(&self, fmt: &mut fmt::Formatter) -> fmt::Result {
        fmt.write_str(self.target.as_str())?;
        Ok(())
    }
}

#[derive(Debug, Default)]
pub struct UISwitcher {}

impl UISwitcher {
    pub fn pick() -> Box<dyn UserInterface> {
        if !user_attended() {
            Box::<AsciiInterface>::default()
        } else {
            Box::<IndicatifInterface>::default()
        }
    }
}

pub trait UserInterface: Send + Sync {
    fn welcome(&self);
    fn farewell(&self);
    fn new_check(&self, key: &str) -> Box<dyn SetupCheck>;
    fn new_subcommand(&self, key: &str) -> Box<dyn SubcommandStatus>;
}

impl UserInterface for FONTSHIPUI {
    fn welcome(&self) {
        self.write().expect(ERROR_UI_WRITE).welcome()
    }
    fn farewell(&self) {
        self.write().expect(ERROR_UI_WRITE).farewell()
    }
    fn new_check(&self, key: &str) -> Box<dyn SetupCheck> {
        self.write().expect(ERROR_UI_WRITE).new_check(key)
    }
    fn new_subcommand(&self, key: &str) -> Box<dyn SubcommandStatus> {
        self.write().expect(ERROR_UI_WRITE).new_subcommand(key)
    }
}

pub trait SubcommandStatus: Send + Sync {
    fn end(&self, status: bool);
    fn error(&mut self, msg: String);
    fn new_target(&mut self, target: MakeTarget);
    fn get_target(&self, target: MakeTarget) -> Option<&Box<dyn JobStatus>>;
}

pub trait SetupCheck: Send + Sync {
    fn end(&self, ret: bool) {
        if ret {
            self.pass()
        } else {
            self.fail()
        }
    }
    fn pass(&self);
    fn fail(&self);
}

pub trait JobStatus: Send + Sync {
    fn push(&self, line: JobBacklogLine);
    fn stdout(&self, line: &str) {
        let line = JobBacklogLine {
            stream: JobBacklogStream::StdOut,
            line: line.into(),
        };
        self.push(line);
    }
    fn stderr(&self, line: &str) {
        let line = JobBacklogLine {
            stream: JobBacklogStream::StdErr,
            line: line.into(),
        };
        self.push(line);
    }
    fn must_dump(&self) -> bool;
    fn dump(&self);
    fn pass(&self) {
        self.pass_msg();
        if CONF.get_bool("debug").unwrap() || self.must_dump()
        // TODO: figure out how to handle output from -p
        // || targets.contains(&"-p".into())
        {
            self.dump();
        }
    }
    fn pass_msg(&self);
    fn fail(&self, code: u32) {
        self.fail_msg(code);
        self.dump();
    }
    fn fail_msg(&self, code: u32);
}

// TODO: implement destroy for job status to catch unfinished jobs

#[derive(Debug, Default)]
pub struct UserInterfaceMessages {
    pub welcome: String,
    // pub farewell: String,
}

impl UserInterfaceMessages {
    pub fn new() -> Self {
        let welcome = LocalText::new("welcome").arg("version", *VERSION).fmt();
        // let farewell = LocalText::new("farewell").arg("duration", time).fmt();
        Self {
            welcome,
            // farewell,
        }
    }
}

#[derive(Debug)]
pub struct SubcommandHeaderMessages {
    pub msg: String,
    pub good_msg: String,
    pub bad_msg: String,
}

impl SubcommandHeaderMessages {
    pub fn new(key: &str) -> Self {
        let msg_key = format!("{key}-header");
        let msg = LocalText::new(msg_key.as_str()).fmt().to_string();
        let good_key = format!("{key}-good");
        let good_msg = LocalText::new(good_key.as_str()).fmt();
        let bad_key = format!("{key}-bad");
        let bad_msg = LocalText::new(bad_key.as_str()).fmt();
        Self {
            msg,
            good_msg,
            bad_msg,
        }
    }
}

#[derive(Debug, Default)]
pub enum JobBacklogStream {
    StdErr,
    #[default]
    StdOut,
}

#[derive(Debug, Default)]
pub struct JobBacklogLine {
    pub stream: JobBacklogStream,
    pub line: String,
}

#[derive(Debug, Default)]
pub struct JobBacklog {
    pub target: String,
    pub lines: Arc<RwLock<Vec<JobBacklogLine>>>,
}

impl JobBacklog {
    pub fn push(&self, line: JobBacklogLine) {
        self.lines.write().unwrap().push(line);
    }
    // pub fn extract(&self) -> Vec<JobBacklogLine> {
    //     self.lines.read().unwrap()
    // }
}
