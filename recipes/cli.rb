remote_file '/usr/local/jenkins/jars/jenkins-cli.jar' do
  source 'http://localhost:8080/jnlpJars/jenkins-cli.jar'
  action :nothing
  subscribes :create, 'service[jenkins]'
  # Add retry logic since it might take a bit for Jenkins to be operational
  retries 3
  retry_delay 5
end
