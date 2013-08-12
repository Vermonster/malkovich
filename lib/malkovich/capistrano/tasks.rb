Capistrano::Configuration.instance.load do

  desc 'Generate .vagrant/shell_provisioner with your publick_key'
  task :vagrant do
    dirname = '.vagrant'
    filename = "#{dirname}/shell_provisioner"

    abort("#{filename} already exists.") if File.exists? filename

    unless File.exists? public_key_filename
      puts "SSH public key #{public_key_filename} does not exist."
      puts "Extracting from #{private_key_filename}..."
      pub = `ssh-keygen -y -f #{private_key_filename}`
      abort("Cancelled.") unless $? == 0
      File.open(public_key_filename, 'w') {|f| f.write pub}
    end
    sh = <<-SH
      adduser #{user} --gecos #{user} --disabled-password
      adduser #{user} admin
      mkdir ~#{user}/.ssh
      echo "#{File.open(public_key_filename).read}" > ~#{user}/.ssh/authorized_keys
      chown #{user}.#{user} ~#{user}/.ssh/authorized_keys
      chmod 600 ~#{user}/.ssh/authorized_keys
    SH

    puts "\nCreating #{filename}"
    Dir.mkdir dirname unless File.exist? dirname
    File.open(filename, 'w') do |f|
        f.write sh
    end
    puts "\nAdd the following line to Vagrantfile:\nconfig.vm.provision :shell, :path => '.vagrant/shell_provisioner'"
  end

  task :uptime do
      run "uptime"
  end

  desc "Upgrade packages and install puppet and build essentials"
  task :bootstrap do
    cmd = <<-SH
  echo 'deb http://apt.puppetlabs.com precise main dependencies' | sudo tee /etc/apt/sources.list.d/puppetlabs.list;
  sudo apt-key adv --keyserver keyserver.ubuntu.com --recv 4BD6EC30;
  sudo apt-get update;
  sudo DEBIAN_FRONTEND=noninteractive apt-get -o Dpkg::Options::="--force-confnew" --force-yes --fix-broken --yes upgrade;
  sudo DEBIAN_FRONTEND=noninteractive apt-get -o Dpkg::Options::="--force-confnew" --force-yes --fix-broken --yes install build-essential openssl libreadline6 libreadline6-dev curl git-core zlib1g zlib1g-dev libssl-dev libyaml-dev libsqlite3-dev sqlite3 libxml2-dev libxslt-dev autoconf libc6-dev ncurses-dev automake libtool bison vim tmux ack-grep;
  sudo DEBIAN_FRONTEND=noninteractive apt-get -o Dpkg::Options::="--force-confnew" --force-yes --fix-broken --yes install puppet ruby1.8 libopenssl-ruby ruby rubygems;
  sudo gem install bundler --no-ri --no-rdoc;
  SH
    run cmd
  end

  desc "Upgrade packages"
  task :upgrade do
    cmd = <<-SH
  sudo apt-get update;
  sudo DEBIAN_FRONTEND=noninteractive apt-get -o Dpkg::Options::="--force-confnew" --force-yes --fix-broken --yes upgrade;
  SH
    run cmd
  end
end
