default["jenkins"]["lts"] = true

# Pin the exact Jenkins package version to install/upgrade to. Leave unset to
# always install whatever is newest in the apt repo. Jenkins does not support
# downgrades, so jenkins::jenkins will refuse to converge if this is set lower
# than the version already installed on the node.
default["jenkins"]["master"]["version"] = nil
