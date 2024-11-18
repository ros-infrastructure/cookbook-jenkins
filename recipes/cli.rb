remote_file '/usr/local/jenkins/jars/jenkins-cli.jar' do
  source 'http://localhost:8080/jnlpJars/jenkins-cli.jar'
  action :create
end
