# Currently hard coded, see clap issue #1880
help-description =
  The command line interface to Fontship,
  a font development toolkit and collaborative work flow.

# Currently hard coded, see clap issue #1880
help-flags-debug =
  Enable extra debug output from tooling

# Currently hard coded, see clap issue #1880
help-flags-language =
  Set language

# Currently hard coded, see clap issue #1880
help-flags-quiet =
  Discard all non-error output messages

# Currently hard coded, see clap issue #1880
help-flags-verbose =
  Enable extra verbose output from tooling

# Currently hard coded, see clap issue #1880
help-subcommand-make =
  Build specified target(s) with ‘make’

# Currently hard coded, see clap issue #1880
help-subcommand-make-target =
  Target as defined by rules in Fontship or project

# Currently hard coded, see clap issue #1880
help-subcommand-setup =
  Show status information about setup, configuration, and build state

# Currently hard coded, see clap issue #1880
help-subcommand-setup-path =
  Path to font project repository

error-not-setup =
  This project path (if it is a project path) is not setup for use with
  Fontship.  Please run run ‘fontship status’ for details or ‘fontship setup’
  to initialize it properly.

error-invalid-language =
  Could not parse BCP47 language tag.

error-invalid-resources =
  Could not find valid BCP47 resource files.

welcome =
  Welcome to Fontship { $version }

outro =
  Fontship run complete

make-header =
  Building target(s) using ‘make’

make-report-start =
  Starting make job for target: { $target }

make-report-end =
  Finished make job for target: { $target }

make-report-fail =
  Failed make job for target: { $target }

make-backlog-start =
  Dumping captured output of ‘make’

make-backlog-end =
  End dump

make-error-unknown-code =
  Make returned an action code Fontship doesn't have a handler for.  The most
  likely cause is the shell helper script being out of sync with the CLI
  binary.  Needless to say this should not have happened. If you are not
  currently hacking on Fontship itself please report this as a bug.

make-error-failed =
  Make failed to execute a recipe.

make-error-process =
  Make failed to execute a build plan.

status-true =
  Yes

status-false =
  No

status-good =
  Everything seems to be ship shape, anchors up!

status-bad =
  Something isn’t seaworthy, run ‘fontship setup’

setup-header =
  Configuring repository for use with Fontship

setup-gitignore-committing =
  Committing updated .gitignore file

setup-gitignore-fresh =
  Existing .gitignore file is up to date

status-header =
  Scanning project status

status-is-repo =
  Is the path a Git repository?

status-is-gha =
  Are we running as a GitHub Action?

status-is-writable =
  Can we write to the project base directory?

status-is-make-executable =
  Is the system’s ‘make’ executable?

status-is-make-gnu =
  Is the system’s ‘make’ a supported version of GNU Make?
