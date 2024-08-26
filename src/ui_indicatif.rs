use crate::config::CONF;
use crate::i18n::LocalText;
use crate::ui::*;
use crate::*;

use console::style;
use indicatif::{HumanDuration, MultiProgress, ProgressBar, ProgressDrawTarget, ProgressStyle};
use std::time::Instant;

fn finalize_bar(bar: ProgressBar, msg: String) {
    let prefix = bar.prefix();
    if !bar.is_hidden() {
        bar.suspend(|| {
            println!("{prefix} {msg}");
        });
    }
    bar.finish_and_clear();
}

#[derive(Debug)]
pub struct IndicatifInterface {
    progress: MultiProgress,
    messages: UserInterfaceMessages,
    started: Instant,
}

impl std::ops::Deref for IndicatifInterface {
    type Target = MultiProgress;
    fn deref(&self) -> &Self::Target {
        &self.progress
    }
}

impl Default for IndicatifInterface {
    fn default() -> Self {
        let progress = MultiProgress::new();
        progress.set_move_cursor(true);
        if CONF.get_bool("passthrough").unwrap() {
            progress.set_draw_target(ProgressDrawTarget::hidden());
        }
        let started = Instant::now();
        let messages = UserInterfaceMessages::new();
        Self {
            progress,
            messages,
            started,
        }
    }
}

impl IndicatifInterface {
    pub fn bar(&self) -> ProgressBar {
        let prefix = style("⛫").cyan().to_string();
        let pstyle = ProgressStyle::with_template("{prefix} {msg}").unwrap();
        let bar = ProgressBar::new_spinner()
            .with_style(pstyle)
            .with_prefix(prefix);
        if CONF.get_bool("passthrough").unwrap() {
            bar.set_draw_target(ProgressDrawTarget::hidden());
        }
        bar
    }
    pub fn show(&self, msg: String) {
        let bar = self.bar();
        let msg = style(msg).cyan().bright().to_string();
        finalize_bar(bar, msg);
    }
}

impl UserInterface for IndicatifInterface {
    fn welcome(&self) {
        if CONF.get_bool("passthrough").unwrap() {
            return;
        }
        let msg = &self.messages.welcome;
        self.show(msg.to_string());
    }
    fn farewell(&self) {
        if CONF.get_bool("passthrough").unwrap() {
            return;
        }
        let time = HumanDuration(self.started.elapsed());
        let msg = LocalText::new("farewell").arg("duration", time).fmt();
        self.show(msg);
    }
    fn new_check(&self, key: &str) -> Box<dyn SetupCheck> {
        Box::new(IndicatifSetupCheck::new(self, key))
    }
    fn new_subcommand(&self, key: &str) -> Box<dyn SubcommandStatus> {
        Box::new(IndicatifSubcommandStatus::new(self, key))
    }
}

pub struct IndicatifSubcommandStatus {
    progress: MultiProgress,
    bar: ProgressBar,
    messages: SubcommandHeaderMessages,
    jobs: JobMap,
}

impl std::ops::Deref for IndicatifSubcommandStatus {
    type Target = ProgressBar;
    fn deref(&self) -> &Self::Target {
        &self.bar
    }
}

impl IndicatifSubcommandStatus {
    pub fn new(ui: &IndicatifInterface, key: &str) -> Self {
        let messages = SubcommandHeaderMessages::new(key);
        let prefix = style("⟳").yellow().to_string();
        let pstyle = ProgressStyle::with_template("{prefix} {msg}").unwrap();
        let bar = ProgressBar::new_spinner()
            .with_style(pstyle)
            .with_prefix(prefix);
        if CONF.get_bool("passthrough").unwrap() {
            bar.set_draw_target(ProgressDrawTarget::hidden());
        }
        let bar = ui.add(bar);
        let msg = style(messages.msg.to_owned()).yellow().bright().to_string();
        bar.set_message(msg);
        Self {
            progress: ui.progress.clone(),
            bar,
            messages,
            jobs: JobMap::new(),
        }
    }
    pub fn pass(&self) {
        if !CONF.get_bool("passthrough").unwrap() {
            return;
        }
        let prefix = style("✔").green().to_string();
        self.set_prefix(prefix);
        let msg = style(self.messages.good_msg.to_owned())
            .green()
            .bright()
            .to_string();
        finalize_bar(self.bar.clone(), msg);
    }
    pub fn fail(&self) {
        if CONF.get_bool("passthrough").unwrap() {
            return;
        }
        let prefix = style("✗").red().to_string();
        self.set_prefix(prefix);
        let msg = style(self.messages.bad_msg.to_owned())
            .red()
            .bright()
            .to_string();
        finalize_bar(self.bar.clone(), msg);
    }
}

impl SubcommandStatus for IndicatifSubcommandStatus {
    fn end(&self, status: bool) {
        (status).then(|| self.pass()).unwrap_or_else(|| self.fail());
    }
    fn error(&mut self, msg: String) {
        if CONF.get_bool("passthrough").unwrap() {
            return;
        }
        self.bar.suspend(|| {
            eprintln!("{}", style(msg).red().dim());
        });
    }
    fn new_target(&mut self, target: MakeTarget) {
        let target_status = Box::new(IndicatifJobStatus::new(self, target.clone()));
        self.jobs.insert(target, target_status);
    }
    fn get_target(&self, target: MakeTarget) -> Option<&Box<dyn JobStatus>> {
        self.jobs.get(&target)
    }
}

#[derive(Debug)]
pub struct IndicatifSetupCheck(ProgressBar);

impl std::ops::Deref for IndicatifSetupCheck {
    type Target = ProgressBar;
    fn deref(&self) -> &Self::Target {
        &self.0
    }
}

impl IndicatifSetupCheck {
    pub fn new(ui: &IndicatifInterface, key: &str) -> Self {
        let msg = LocalText::new(key).fmt();
        let bar = if CONF.get_bool("passthrough").unwrap() {
            ProgressBar::hidden()
        } else if CONF.get_bool("debug").unwrap() || CONF.get_bool("verbose").unwrap() {
            let bar = ProgressBar::new_spinner()
                .with_prefix("-")
                .with_style(ProgressStyle::with_template("{msg}").unwrap());
            ui.add(bar)
        } else {
            ProgressBar::hidden()
        };
        if !bar.is_hidden() {
            bar.set_message(msg);
        }
        Self(bar)
    }
}

impl SetupCheck for IndicatifSetupCheck {
    fn pass(&self) {
        if CONF.get_bool("passthrough").unwrap() {
            return;
        }
        let msg = self.message();
        let yes = style(LocalText::new("setup-true").fmt())
            .green()
            .to_string();
        finalize_bar(self.0.clone(), format!("{msg} {yes}"));
    }
    fn fail(&self) {
        if CONF.get_bool("passthrough").unwrap() {
            return;
        }
        let msg = self.message();
        let no = style(LocalText::new("setup-false").fmt()).red().to_string();
        finalize_bar(self.0.clone(), format!("{msg} {no}"));
    }
}

#[derive(Debug)]
pub struct IndicatifJobStatus {
    bar: ProgressBar,
    target: MakeTarget,
    log: JobBacklog,
}

impl std::ops::Deref for IndicatifJobStatus {
    type Target = ProgressBar;
    fn deref(&self) -> &Self::Target {
        &self.bar
    }
}

impl IndicatifJobStatus {
    // pub fn new(ui: &IndicatifInterface, mut target: String) -> Self {
    pub fn new(subcommand: &IndicatifSubcommandStatus, target: MakeTarget) -> Self {
        // Without this, copying the string in the terminal as a word brings a U+2069 with it
        // c.f. https://github.com/XAMPPRocky/fluent-templates/issues/72
        let mut printable_target: String = target.to_string();
        printable_target.push(' ');
        let msg = style(
            LocalText::new("make-report-start")
                .arg("target", style(printable_target).white().bold())
                .fmt(),
        )
        .yellow()
        .bright()
        .to_string();
        let pstyle = ProgressStyle::with_template("{spinner} {msg}")
            .unwrap()
            .tick_strings(&["↻", "✔"]);
        let bar = ProgressBar::new_spinner()
            .with_prefix("✔") // not relevant for spinner, but we use it for our finalized mode
            .with_style(pstyle)
            .with_message(msg);
        if CONF.get_bool("passthrough").unwrap() {
            bar.set_draw_target(ProgressDrawTarget::hidden());
        }
        let bar = subcommand.progress.add(bar);
        bar.tick();
        Self {
            bar,
            target,
            log: JobBacklog::default(),
        }
    }
}

impl JobStatus for IndicatifJobStatus {
    fn push(&self, line: JobBacklogLine) {
        self.log.push(line);
    }
    fn must_dump(&self) -> bool {
        self.target.starts_with("debug")
    }
    fn dump(&self) {
        let start = LocalText::new("make-backlog-start")
            .arg("target", self.target.clone())
            .fmt();
        let start = format!("{} {start}", style(style("┄┄┄┄┄").cyan()));
        self.bar.println(start);
        let was_hidden = self.bar.is_hidden();
        if was_hidden {
            self.bar.set_draw_target(ProgressDrawTarget::stdout());
        }
        let lines = self.log.lines.read().unwrap();
        for line in lines.iter() {
            let msg = style(line.line.as_str()).dim().to_string();
            self.bar.println(msg);
        }
        if was_hidden {
            self.bar.set_draw_target(ProgressDrawTarget::hidden());
        }
        let end = LocalText::new("make-backlog-end").fmt();
        let end = format!("{} {end}", style(style("┄┄┄┄┄").cyan()));
        self.bar.println(end);
    }
    fn pass_msg(&self) {
        let target = self.target.clone();
        let allow_hide = !CONF.get_bool("debug").unwrap() && !CONF.get_bool("verbose").unwrap();
        if allow_hide && target.starts_with(".fontship") {
            // UI.remove(&self.bar);
        } else {
            let msg = style(
                LocalText::new("make-report-pass")
                    .arg("target", style(target).white().bold())
                    .fmt(),
            )
            .green()
            .bright()
            .to_string();
            finalize_bar(self.bar.clone(), msg);
        }
    }
    fn fail_msg(&self, code: u32) {
        let msg = style(
            LocalText::new("make-report-fail")
                .arg("target", style(self.target.clone()).white().bold())
                .arg("code", style(code).white().bold())
                .fmt(),
        )
        .red()
        .bright()
        .to_string();
        finalize_bar(self.bar.clone(), msg);
    }
}
