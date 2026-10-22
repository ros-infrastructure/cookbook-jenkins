default["jenkins"]["lts"] = true

# Pin the exact Jenkins package version to install/upgrade to. Leave unset to
# always install whatever is newest in the apt repo. Jenkins does not support
# downgrades, so jenkins::jenkins will refuse to converge if this is set lower
# than the version already installed on the node.
default["jenkins"]["master"]["version"] = nil

# needrestart integration (see jenkins::needrestart). When a library Jenkins
# uses is upgraded, needrestart's restart hook for jenkins.service arms a
# one-shot systemd timer instead of restarting Jenkins immediately. The timer
# runs `jenkins-cli safe-restart` at the next `calendar` occurrence, letting
# running builds finish first.
default["jenkins"]["needrestart"]["calendar"] = "*-*-* 03:00:00"
default["jenkins"]["needrestart"]["url"] = "http://localhost:8080"
# Optional path to a root-readable file containing `user:api_token`, passed to
# the CLI as `-auth @file`. Leave unset if the CLI is usable anonymously.
default["jenkins"]["needrestart"]["auth_file"] = nil
