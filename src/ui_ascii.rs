use crate::i18n::LocalText;
use crate::ui::*;
use crate::*;

use console::style;
use indicatif::HumanDuration;
use std::time::Instant;

#[derive(Debug)]
pub struct AsciiInterface {
    messages: UserInterfaceMessages,
    started: Instant,
}

impl Default for AsciiInterface {
    fn default() -> Self {
        let started = Instant::now();
        let messages = UserInterfaceMessages::new();
        Self { messages, started }
    }
}

impl UserInterface for AsciiInterface {
    fn welcome(&self) {
        if CONF.get_bool("passthrough").unwrap() {
            return;
        }
        let welcome = &self.messages.welcome;
        let welcome = style(welcome).cyan();
        println!("{welcome}");
    }
    fn farewell(&self) {
        if CONF.get_bool("passthrough").unwrap() {
            return;
        }
        let time = HumanDuration(self.started.elapsed());
        let farewell = LocalText::new("farewell").arg("duration", time).fmt();
        let farewell = style(farewell).cyan();
        println!("{farewell}");
    }
    fn new_check(&self, key: &str) -> Box<dyn SetupCheck> {
        Box::new(AsciiSetupCheck::new(self, key))
    }
    fn new_subcommand(&self, key: &str) -> Box<dyn SubcommandStatus> {
        Box::new(AsciiSubcommandStatus::new(key))
    }
}

#[derive(Default)]
pub struct AsciiSubcommandStatus {
    jobs: JobMap,
}

impl AsciiSubcommandStatus {
    fn new(_key: &str) -> Self {
        Self {
            jobs: JobMap::new(),
        }
    }
}

impl SubcommandStatus for AsciiSubcommandStatus {
    fn end(&self, _status: bool) {}
    fn error(&mut self, msg: String) {
        if CONF.get_bool("passthrough").unwrap() {
            return;
        }
        let msg = style(msg).red().dim();
        eprintln!("{msg}");
    }
    fn new_target(&mut self, target: MakeTarget) {
        let target_status = Box::new(AsciiJobStatus::new(target.clone()));
        self.jobs.insert(target, target_status);
    }
    fn get_target(&self, target: MakeTarget) -> Option<&Box<dyn JobStatus>> {
        self.jobs.get(&target)
    }
}

#[derive(Debug, Default)]
pub struct AsciiSetupCheck {
    message: String,
}

impl AsciiSetupCheck {
    fn new(_ui: &AsciiInterface, key: &str) -> Self {
        let message = LocalText::new(key).fmt();
        Self { message }
    }
}

impl SetupCheck for AsciiSetupCheck {
    fn pass(&self) {
        if CONF.get_bool("passthrough").unwrap() {
            return;
        }
        let msg = &self.message;
        let yes = LocalText::new("setup-true").fmt();
        let yes = style(yes).green();
        println!("{msg} {yes}");
    }
    fn fail(&self) {
        if CONF.get_bool("passthrough").unwrap() {
            return;
        }
        let msg = &self.message;
        let no = LocalText::new("setup-false").fmt();
        let no = style(no).red();
        eprintln!("{msg} {no}");
    }
}

#[derive(Debug, Default)]
pub struct AsciiJobStatus {
    target: MakeTarget,
    log: JobBacklog,
}

impl AsciiJobStatus {
    fn new(target: MakeTarget) -> Self {
        if !CONF.get_bool("passthrough").unwrap() {
            // Without this, copying the string in the terminal as a word brings a U+2069 with it
            // c.f. https://github.com/XAMPPRocky/fluent-templates/issues/72
            let mut printable_target: String = target.to_string();
            printable_target.push(' ');
            let printable_target = style(printable_target).white().bold();
            let msg = LocalText::new("make-report-start")
                .arg("target", printable_target)
                .fmt();
            let msg = style(msg).yellow().bright();
            println!("{msg}");
        }
        Self {
            target,
            log: JobBacklog::default(),
        }
    }
}

impl JobStatus for AsciiJobStatus {
    fn push(&self, line: JobBacklogLine) {
        self.log.push(line);
    }
    fn must_dump(&self) -> bool {
        self.target.starts_with("debug")
    }
    fn dump(&self) {
        if !CONF.get_bool("passthrough").unwrap() {
            let start = LocalText::new("make-backlog-start")
                .arg("target", self.target.clone())
                .fmt();
            println!("{}{start}", style("----- ").cyan());
        }
        let lines = self.log.lines.read().unwrap();
        for line in lines.iter() {
            match line.stream {
                JobBacklogStream::StdOut => {
                    let line = style(line.line.clone()).dim();
                    println!("{}", line);
                }
                JobBacklogStream::StdErr => {
                    let line = style(line.line.clone()).dim();
                    eprintln!("{}", line);
                }
            }
        }
        if !CONF.get_bool("passthrough").unwrap() {
            let end = LocalText::new("make-backlog-end").fmt();
            println!("{} {end}", style("----- ").cyan());
        }
    }
    fn pass_msg(&self) {
        if CONF.get_bool("passthrough").unwrap() {
            return;
        }
        // Without this, copying the string in the terminal as a word brings a U+2069 with it
        // c.f. https://github.com/XAMPPRocky/fluent-templates/issues/72
        let mut printable_target: String = self.target.to_string();
        printable_target.push(' ');
        let target = printable_target;
        let target = style(target).white().bold();
        let msg = LocalText::new("make-report-pass")
            .arg("target", target)
            .fmt();
        let msg = style(msg).green().bright();
        println!("{msg}")
    }
    fn fail_msg(&self, code: u32) {
        if CONF.get_bool("passthrough").unwrap() {
            return;
        }
        // Without this, copying the string in the terminal as a word brings a U+2069 with it
        let mut printable_target: String = self.target.to_string();
        printable_target.push(' ');
        let target = printable_target;
        let target = style(target).white().bold();
        let msg = LocalText::new("make-report-fail")
            .arg("target", target)
            .arg("code", code)
            .fmt();
        let msg = style(msg).red().bright();
        eprintln!("{msg}")
    }
}
