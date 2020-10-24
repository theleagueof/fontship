help-description =
  The command line interface to Fontship,
  a font development toolkit and collaborative work flow.

help-flags-debug =
  Enable extra debug output from tooling

help-flags-language =
  Set language

help-flags-quiet =
  Discard all non-error output messages

help-flags-verbose =
  Enable extra verbose output from tooling

help-subcommand-make =
  Build specified target(s) with `make`

help-subcommand-make-target =
  Target as defined in Fontship or project rules

help-subcommand-setup =
  Show status information about setup, configuration, and build state

help-subcommand-setup-path =
  Path to font project repository

error-not-setup =
  Project not setup for use with Fontship, run `fontship status` for details or
  `fontship setup` to initialize.

error-invalid-language =
  Could not parse BCP47 language tag.

error-invalid-resources =
  Could not find valid BCP47 resource files.

welcome =
  Welcome to Fontship version { $version }!

outro =
  Finished Fontship run.

make-header =
  Building target(s) with `make`…

make-report-start =
  Start make job for { $target }

make-report-end =
  Completed make job for { $target }

make-report-fail =
  Failed make job for { $target }

make-backlog-start =
  Dumping backlog

make-backlog-end =
  End backlog dump

status-true =
  Yes

status-false =
  No

status-good =
  Everything seems to be ship shape!

status-bad =
  Not everything is seaworthy, run `fontship setup`.

setup-header =
  Configuring repository for use with Fontship…

status-header =
  Project status report…

status-is-repo =
  Are we in a Git repository?

status-is-gha =
  Are we running as a GitHub Action?

status-is-writable =
  Can we write to the project base directory?

status-is-make-executable =
 Can we execute the system's `make`?

status-is-make-gnu =
  Is the system's `make` GNU Make?
