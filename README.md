# jenkins

A fresh start on a Jenkins cookbook that supports current (2024) Jenkins packaging practices.

Currently targets Ubuntu and is likely to support Debian-derived platforms for the foreseeable future.


## needrestart integration

`jenkins::needrestart` installs a needrestart `restart.d` hook for `jenkins.service`. When an upgrade makes needrestart want to restart Jenkins, the hook arms a one-shot systemd timer (`jenkins-deferred-maintenance`) for `node['jenkins']['needrestart']['calendar']` (default `*-*-* 03:00:00`). The timer runs `/usr/local/bin/jenkins-safe-restart`, which calls `jenkins-cli safe-restart` (requires `jenkins::cli`) so running builds finish first. Logs are tagged `jenkins-maintenance` in the journal. The host is never rebooted.

Set `node['jenkins']['needrestart']['auth_file']` to a root-readable `user:api_token` file if the CLI needs authentication.

needrestart only runs `restart.d` hooks in automatic mode (`$nrconf{restart} = 'a'`); Ubuntu's default falls back to list-only under unattended-upgrades, so configure that separately.
