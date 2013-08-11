Capistrano::Configuration.instance.load do
  _cset(:stage) { abort "please specify stage" }

  set :user, 'ubuntu'
  set :scm, :git
  set :keep_releases, 3
  set :deploy_via, :remote_cache
  set :use_sudo, false
  set(:deploy_to) { "/srv/#{application}-#{stage}" }
  set(:branch) { stage }
  set(:facter_vars) { "" }

  default_run_options[:pty]     = true
  ssh_options[:forward_agent]   = true

end
