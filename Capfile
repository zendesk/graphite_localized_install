#!/usr/bin/env ruby

load 'deploy'
require 'capistrano_colors'

set :application, "graphite_install"
set :repository,  "git@github.com:quanghiem/graphite_localized_install.git"

set :scm, :git

role :web, "graphite"
role :app, "graphite"
role :db,  "graphite", :primary => true

set :default_shell, "/bin/bash"

set :deploy_to, "/data/graphite"
set :user, "zendesk"
set :runner, "zendesk"

namespace :deploy do
  task :start do
    run "sudo /etc/init.d/apache2 start"
    run "#{current_path}/bin/carbon-cache.py start"
  end

  task :stop do
    run "sudo /etc/init.d/apache2 stop"
    run "#{current_path}/bin/carbon-cache.py stop"
  end

  task :restart, :roles => :app, :except => { :no_release => true } do
    run "[[ -f /usr/bin/figlet ]] && figlet restarting | perl -pe 's{( +)}{chr(46) x length($1)}e'"
    deploy.stop
    deploy.start
    run "sudo sv restart statsd"
  end

  task :finalize_update do; end

  task :setup_perms do
    run "[[ -f /usr/bin/figlet ]] && figlet setup perms | perl -pe 's{( +)}{chr(46) x length($1)}e'"
    run "sudo chown -Rv #{user}.#{user} #{deploy_to}"
  end

  task :apache_perms do
    run "[[ -f /usr/bin/figlet ]] && figlet apache perms | perl -pe 's{( +)}{chr(46) x length($1)}e'"
    run "sudo chown -Rv www-data:www-data #{release_path}/storage/ #{shared_path}/log/"
    run "sudo chown -Rv #{user}.#{user} #{shared_path}/log/carbon-cache-a/"
  end

  task :virtualenv do
    run <<-SCRIPT
      set -e;
      [[ -f /usr/bin/figlet ]] && figlet virtualenv | perl -pe 's{( +)}{chr(46) x length($1)}e';
      cd #{release_path};
      virtualenv -q .pvm;
      rm distribute-0.6.10.tar.gz;
      source .pvm/bin/activate;

      [[ -f /usr/bin/figlet ]] && figlet twisted | perl -pe 's{( +)}{chr(46) x length($1)}e';
      easy_install -q twisted;

      [[ -f /usr/bin/figlet ]] && figlet django | perl -pe 's{( +)}{chr(46) x length($1)}e';
      easy_install -q django;

      [[ -f /usr/bin/figlet ]] && figlet django-tagging | perl -pe 's{( +)}{chr(46) x length($1)}e';
      easy_install -q django-tagging;
    SCRIPT
  end

  task :graphite do
    run <<-SCRIPT
      set -e;
      cd #{release_path};
      source .pvm/bin/activate;
      cd src/;

      [[ -f /usr/bin/figlet ]] && figlet whisper | perl -pe 's{( +)}{chr(46) x length($1)}e';
      tar xfz whisper-0.9.9.tar.gz;
      cd whisper-0.9.9/;
      python setup.py --quiet install;
      cd ..;
      rm -r whisper-0.9.9/;

      [[ -f /usr/bin/figlet ]] && figlet carbon | perl -pe 's{( +)}{chr(46) x length($1)}e';
      tar xfz carbon-0.9.9.tar.gz;
      cd carbon-0.9.9/;
      sed -i s#"/opt/graphite"#"#{release_path}"# setup.cfg;
      python setup.py --quiet install;
      cd ..;
      rm -r carbon-0.9.9/;

      [[ -f /usr/bin/figlet ]] && figlet graphite-web | perl -pe 's{( +)}{chr(46) x length($1)}e';
      tar xfz graphite-web-0.9.9.tar.gz;
      cd graphite-web-0.9.9/;
      sed -i s#"/opt/graphite"#"#{release_path}"# setup.cfg;
      python setup.py --quiet install;
      cd ..;
      rm -r graphite-web-0.9.9/;
    SCRIPT
  end

  task :config do
    run <<-SCRIPT
      set -e;
      [[ -f /usr/bin/figlet ]] && figlet graphite configs| perl -pe 's{( +)}{chr(46) x length($1)}e';
      cd #{release_path}/conf/;
      cp -v carbon.conf.example carbon.conf;
      cp -v storage-schemas.conf.example storage-schemas.conf;
      mkdir -pv example/;
      mv -v *.example example/;

      [[ -f /usr/bin/figlet ]] && figlet apache configs| perl -pe 's{( +)}{chr(46) x length($1)}e';
      cd #{release_path};
      cp -v src/myvirtualdjango.py webapp/;
      cp -v src/graphite.apache.conf conf/;
      sudo ln -sfv #{current_path}/conf/graphite.apache.conf /etc/apache2/sites-enabled/420-graphite;
    SCRIPT
  end

  task :database do
    run <<-SCRIPT
      set -e;
      [[ -f /usr/bin/figlet ]] && figlet database | perl -pe 's{( +)}{chr(46) x length($1)}e';
      cd #{current_path}/;
      source .pvm/bin/activate;
      cd webapp/graphite/;
      echo no | python manage.py syncdb;
      sudo chown -v www-data.www-data #{shared_path}/storage/graphite.db;
    SCRIPT
  end

  task :symlink_storage, :except => { :no_release => true } do
    run <<-SCRIPT
      set -e;
      [[ -f /usr/bin/figlet ]] && figlet symlink storage | perl -pe 's{( +)}{chr(46) x length($1)}e';
      rm -rfv #{latest_release}/storage;
      ln -s #{shared_path}/storage #{latest_release}/storage;
    SCRIPT
  end

  task :mkdir_storage do
    run <<-SCRIPT
    set -e;
    [[ -f /usr/bin/figlet ]] && figlet mkdir storage | perl -pe 's{( +)}{chr(46) x length($1)}e';
    mkdir -pv #{shared_path}/storage;
    mkdir -pv #{shared_path}/storage/lists/;
    mkdir -pv #{shared_path}/storage/rrd/;
    mkdir -pv #{shared_path}/storage/whisper/;
    mkdir -pv #{shared_path}/log/webapp/;
    ln -sfv #{shared_path}/log #{shared_path}/storage/log;
    SCRIPT
  end

  task :statsd do
    run <<-SCRIPT
    set -e;
    [[ -f /usr/bin/figlet ]] && figlet statsd | perl -pe 's{( +)}{chr(46) x length($1)}e';
    cd #{latest_release}/;
    git clone https://github.com/etsy/statsd.git;
    ln -sfv #{deploy_to}/config/local.js #{latest_release}/statsd/local.js
    SCRIPT
  end
end

after "deploy:setup","deploy:setup_perms","deploy:mkdir_storage"
after "deploy:update_code","deploy:virtualenv"
after "deploy:virtualenv","deploy:graphite","deploy:statsd"
after "deploy:graphite","deploy:config"
after "deploy:config","deploy:symlink_storage"
after "deploy:symlink_storage","deploy:apache_perms"

