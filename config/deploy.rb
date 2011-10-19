set :application, "graphite_install"
set :repository,  "git@github.com:quanghiem/graphite_install.git"

set :scm, :git

role :web, "richard2"
role :app, "richard2"
role :db,  "richard2", :primary => true

set :deploy_to, "/data/graphite"
set :user, "zendesk"
set :runner, "zendesk"

namespace :deploy do
  task :start do ; end
  task :stop do ; end
  task :restart, :roles => :app, :except => { :no_release => true } do
    run "#{try_sudo} touch #{File.join(current_path,'tmp','restart.txt')}"
  end

  task :permissions do
    run "sudo chown -Rfv #{user}.#{user} #{deploy_to}"
  end
end

after  "deploy:setup","deploy:permissions"
