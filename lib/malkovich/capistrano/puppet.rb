Capistrano::Configuration.instance.load do
  namespace :puppet do
    Dir['puppet/manifests/*'].map{|s| s.split('/').last.split('.').first.to_sym}.each do |manifest|
      desc "apply #{manifest} manifest to server with #{manifest} role"
      task manifest, :roles => manifest do
        upload "puppet", deploy_to, :via => :scp, :recursive => true
        run "cd #{deploy_to}/puppet && sudo puppet apply #{puppet_opts} manifests/#{manifest}.pp"
      end
    end
  end
end
