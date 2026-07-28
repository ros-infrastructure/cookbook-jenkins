# Jenkins must actually be serving requests for this to succeed. If it's
# already running (e.g. a re-converge), download right away; otherwise wait
# for service[jenkins] to (re)start it before trying.
jenkins_running = system('systemctl is-active --quiet jenkins')

remote_file '/usr/local/jenkins/jars/jenkins-cli.jar' do
  source 'http://localhost:8080/jnlpJars/jenkins-cli.jar'
  # Add retry logic since it might take a bit for Jenkins to be operational
  retries 3
  retry_delay 5

  if jenkins_running
    action :create_if_missing
  else
    action :nothing
    subscribes :create, 'service[jenkins]', :delayed
  end
end
