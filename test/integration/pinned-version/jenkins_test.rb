# Chef InSpec test for recipe jenkins::jenkins with
# node['jenkins']['master']['version'] pinned to a specific, older release.
#
# Covers the version-pinning branch of the `package` resource, which is
# otherwise untested by the `default` suite (which always installs
# whatever is newest). This intentionally installs an old release, so it
# only checks that the exact pinned version landed -- it does not assert
# that the (out of date) Jenkins service comes up cleanly under a newer JDK.

describe package('jenkins') do
  it { should be_installed }
  its('version') { should cmp '2.401.3' }
end
