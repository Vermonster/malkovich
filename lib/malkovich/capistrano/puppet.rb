Capistrano::Configuration.instance.load do
  namespace :puppet do
    Dir['puppet/manifests/*'].map{|s| s.split('/').last.split('.').first.to_sym}.each do |manifest|
      desc "apply #{manifest} manifest to server with #{manifest} role"
      task manifest, :roles => manifest do
        upload "puppet", deploy_to, :via => :scp, :recursive => true
        run "cd #{deploy_to}/puppet && sudo FACTER_APP=#{application} FACTER_STAGE=#{stage} #{facter_vars} puppet apply --verbose --modulepath=modules manifests/#{manifest}.pp"
      end
    end
  end
end

