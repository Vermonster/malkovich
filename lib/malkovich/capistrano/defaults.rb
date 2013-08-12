Capistrano::Configuration.instance.load do
  _cset(:stage) { abort "please specify stage" }

  set :application, 'application'
  set :user, 'ubuntu'
  set :use_sudo, false
  set(:deploy_to) { "/home/#{user}" }

  set(:facter_vars) { "" }

  default_run_options[:pty]     = true
  ssh_options[:forward_agent]   = true

  set :private_key_filename, "#{ENV['HOME']}/.ssh/id_rsa"
  set :public_key_filename, "#{ENV['HOME']}/.ssh/id_rsa.pub"

  set :apt_get_cmd, %|DEBIAN_FRONTEND=noninteractive apt-get -o Dpkg::Options::="--force-confnew" --force-yes --fix-broken --yes|

  set :essential_packages, "build-essential openssl libreadline6 libreadline6-dev curl
                              git-core zlib1g zlib1g-dev libssl-dev libyaml-dev libsqlite3-dev
                              sqlite3 libxml2-dev libxslt-dev autoconf libc6-dev ncurses-dev
                              automake libtool bison"

  set :bonus_packages, "vim tmux ack-grep"

  set :puppet_packages, "puppet ruby1.8 libopenssl-ruby ruby rubygems"
end
