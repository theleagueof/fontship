use crate::cli::Cli;
use crate::Result;

use config::{Config, Environment};
use std::{env, sync};

static ERROR_CONFIG_WRITE: &str = "Unable to gain write lock on global app config";
static ERROR_CONFIG_READ: &str = "Unable to gain read lock on global app config";

lazy_static! {
    pub static ref CONF: sync::RwLock<Config> = sync::RwLock::new(Config::default());
}

impl CONF {
    #[allow(deprecated)]
    pub fn defaults(&self) -> Result<()> {
        let mut config = self.write().expect(ERROR_CONFIG_WRITE);
        config
            .set_default("debug", false)?
            .set_default("quiet", false)?
            .set_default("verbose", false)?
            .set_default("language", crate::DEFAULT_LOCALE)?
            .set_default("passthrough", false)?
            .set_default("project", "./")?
            .set_default("sourcedir", "sources")?
            .set_default("builddir", ".fontship")?;
        Ok(())
    }

    #[allow(deprecated)]
    pub fn merge_env(&self) -> Result<()> {
        let mut config = self.write().expect(ERROR_CONFIG_WRITE);
        if let Some(lang) = env::var_os("LANG") {
            if lang.len() > 0 && env::var_os("FONTSHIP_LANGUAGE").is_none() {
                env::set_var("FONTSHIP_LANGUAGE", lang)
            }
        }
        if env::var("RUNNER_DEBUG").is_ok() {
            env::set_var("FONTSHIP_DEBUG", env::var("RUNNER_DEBUG")?)
        }
        config.merge(Environment::with_prefix("fontship"))?;
        Ok(())
    }

    pub fn merge_args(&self, args: &Cli) -> Result<()> {
        if args.debug {
            self.set_bool("debug", true)?;
            self.set_bool("verbose", true)?;
        } else if args.verbose {
            self.set_bool("verbose", true)?;
        } else if args.quiet {
            self.set_bool("quiet", true)?;
        }
        if args.passthrough {
            self.set_bool("passthrough", true)?;
        }
        if let Some(path) = &args.project.to_str() {
            self.set_str("project", path)?;
        }
        if let Some(language) = &args.language {
            self.set_str("language", language)?;
        };
        Ok(())
    }

    #[allow(deprecated)]
    pub fn set_bool(&self, key: &str, val: bool) -> Result<()> {
        self.write().expect(ERROR_CONFIG_WRITE).set(key, val)?;
        Ok(())
    }

    pub fn get_bool(&self, key: &str) -> Result<bool> {
        Ok(self.read().expect(ERROR_CONFIG_READ).get_bool(key)?)
    }

    #[allow(deprecated)]
    pub fn set_str(&self, key: &str, val: &str) -> Result<()> {
        self.write().expect(ERROR_CONFIG_WRITE).set(key, val)?;
        Ok(())
    }

    pub fn get_string(&self, key: &str) -> Result<String> {
        Ok(self.read().expect(ERROR_CONFIG_READ).get_string(key)?)
    }
}
