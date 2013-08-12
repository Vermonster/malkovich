Capistrano::Configuration.instance.load do
  _cset(:stage) { abort "please specify stage" }

  set :user, 'ubuntu'
  set :use_sudo, false
  set(:deploy_to) { "/home/#{user}" }

  set(:facter_vars) { "" }

  default_run_options[:pty]     = true
  ssh_options[:forward_agent]   = true

  set :private_key_filename, "#{ENV['HOME']}/.ssh/id_rsa"
  set :public_key_filename, "#{ENV['HOME']}/.ssh/id_rsa.pub"
end
