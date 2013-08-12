Capistrano::Configuration.class_eval do
  def define_puppet_tasks(*puppet_tasks)
    namespace :puppet do
      puppet_tasks.each do |task_name|

        desc "apply #{task_name} manifest to server with #{task_name} role"
        task task_name, :roles => :"#{task_name}" do
          upload "puppet", deploy_to, :via => :scp, :recursive => true
          run "cd #{deploy_to}/puppet && sudo FACTER_APP=#{application} FACTER_STAGE=#{stage} #{facter_vars} puppet apply --verbose --modulepath=modules manifests/#{task_name}.pp"
        end
      end
    end
  end
end


