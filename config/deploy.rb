set :application, "graphite_install"
set :repository,  "git@github.com:quanghiem/graphite_install.git"

set :scm, :git

role :web, "richard2"
role :app, "richard2"
role :db,  "richard2", :primary => true

set :default_shell, "/bin/bash"

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

  task :virtualenv do
    run <<-SCRIPT
      set -e;
      [[ -f /usr/bin/figlet ]] && figlet virtualenv | perl -pe 's{( +)}{chr(46) x length($1)}e';
      cd #{release_path};
      virtualenv .pvm;
      source .pvm/bin/activate;

      [[ -f /usr/bin/figlet ]] && figlet twisted | perl -pe 's{( +)}{chr(46) x length($1)}e';
      easy_install twisted;

      [[ -f /usr/bin/figlet ]] && figlet django | perl -pe 's{( +)}{chr(46) x length($1)}e';
      easy_install django;

      [[ -f /usr/bin/figlet ]] && figlet django-tagging | perl -pe 's{( +)}{chr(46) x length($1)}e';
      easy_install django-tagging;
    SCRIPT
  end
end

after "deploy:update","deploy:virtualenv"
after "deploy:setup","deploy:permissions"
