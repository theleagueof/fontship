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
  Setup a font project for use with Fontship

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

error-no-remote =
  Git repository does not have a working remote named 'origin'.

error-no-path =
  Cannot parse directory path.

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

make-error =
  Failed to execute a subprocess for ‘make’.

make-error-unfinished =
  Make reported outdated targets were not built.

make-error-build =
  Make failed to parse or execute a build plan.

make-error-target =
  Make failed to execute a recipe.

make-error-unknown =
  Make returned unknown error.

setup-header =
  Configuring repository for use with Fontship

setup-true =
  Yes

setup-false =
  No

setup-good =
  Everything seems to be ship shape, anchors up!

setup-bad =
  Something isn’t seaworthy, run ‘fontship setup’

setup-is-repo =
  Is the path a Git repository?

setup-is-writable =
  Can we write to the project base directory?

setup-is-make-executable =
  Is the system’s ‘make’ executable?

setup-is-make-gnu =
  Is the system’s ‘make’ a supported version of GNU Make?

setup-gitignore-committing =
  Committing updated .gitignore file

setup-gitignore-fresh =
  Existing .gitignore file is up to date

setup-short-shas =
  Setting default length of short SHA hashes in repository

status-header =
  Scanning project status

status-is-gha =
  Are we running as a GitHub Action?
