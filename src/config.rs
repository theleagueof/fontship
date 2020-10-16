use crate::cli::Cli;
use config::{Config, Environment};
use std::{error, result, sync};

static ERROR_CONFIG_WRITE: &str = "Unable to gain write lock on global app config";
static ERROR_CONFIG_READ: &str = "Unable to gain read lock on global app config";

lazy_static! {
    pub static ref CONFIG: sync::RwLock<Config> = sync::RwLock::new(Config::default());
}

type Result<T> = result::Result<T, Box<dyn error::Error>>;

impl CONFIG {
    pub fn defaults(&self) -> Result<()> {
        self.write()
            .expect(ERROR_CONFIG_WRITE)
            .set_default("debug", false)?
            .set_default("quiet", false)?
            .set_default("verbose", false)?;
        Ok(())
    }

    pub fn from_env(&self) -> Result<()> {
        self.write()
            .expect(ERROR_CONFIG_WRITE)
            .merge(Environment::with_prefix("fontship"))?;
        Ok(())
    }

    pub fn from_args(&self, args: &Cli) -> Result<()> {
        if args.debug {
            self.set_bool("debug", true)?;
        }
        if args.quiet {
            self.set_bool("quiet", true)?;
        }
        if args.verbose {
            self.set_bool("verbose", true)?;
        }
        Ok(())
    }

    pub fn set_bool(&self, key: &str, val: bool) -> Result<()> {
        self.write().expect(ERROR_CONFIG_WRITE).set(key, val)?;
        Ok(())
    }

    pub fn get_bool(&self, key: &str) -> Result<bool> {
        Ok(self.read().expect(ERROR_CONFIG_READ).get_bool(key)?)
    }

    pub fn set_str(&self, key: &str, val: &str) -> Result<()> {
        self.write().expect(ERROR_CONFIG_WRITE).set(key, val)?;
        Ok(())
    }

    pub fn get_string(&self, key: &str) -> Result<String> {
        Ok(self.read().expect(ERROR_CONFIG_READ).get_str(key)?)
    }
}
