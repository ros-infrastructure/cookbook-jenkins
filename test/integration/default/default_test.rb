# Chef InSpec test for recipe jenkins::default
#
# The Chef InSpec reference, with examples and extensive documentation, can be
# found at https://docs.chef.io/inspec/resources/

# Jenkins should be up and serving requests by the end of the suite's run
# list (jenkins::jenkins enables/starts the service, jenkins::cli waits for
# it to come up before downloading the CLI jar).
describe port(8080) do
  it { should be_listening }
end
