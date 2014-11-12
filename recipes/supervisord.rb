set_default(:supervisord_password) { Capistrano::CLI.password_prompt 'Supervisord Interface Password: ' }

namespace :supervisord do

  desc 'Install all Supervisord files'
  task :install do
    # unicorn herder
    run "#{sudo} apt-get -y install python-dev"
    run "#{sudo} apt-get -y install python-setuptools"
    run "#{sudo} easy_install pip"
    run "#{sudo} pip install unicornherder"
    # supervisord
    run "#{sudo} pip install supervisor"
  end
  after 'deploy:install', 'supervisord:install'

  desc 'Setup all Supervisord configuration'
  task :setup do
    template "supervisord.conf.erb", "#{shared_path}/supervisord.conf"
    template "supervisord.conf.start.erb", "#{shared_path}/supervisord.conf.start"
    run "#{sudo} mv #{shared_path}/supervisord.conf.start /etc/init/supervisord.#{application}.conf"
    run "#{sudo} start supervisord.#{application}"
  end
  after 'deploy:setup', 'supervisord:setup'

  desc 'Start Supervisord'
  task :start do
    run "cd #{shared_path} && supervisord"
  end

  desc 'Stop Supervisord'
  task :stop do
    run "#{sudo} stop supervisord.#{application}"
  end

  desc 'Reread Supervisord (reloads configuration and restart all)'
  task :reread do
    run "cd #{shared_path} && supervisorctl reread"
  end

  desc 'Upate Supervisord (only reloads configuration)'
  task :update do
    run "cd #{shared_path} && supervisorctl update"
  end

  desc 'Restart our app'
  task :restart_app do
    run "cd #{shared_path} && supervisorctl restart #{application}:*"
  end

  commands = {
    'start' => 'start',
    'stop' => 'stop',
    'restart' => 'restart_app'
  }

  commands.each do |deploy, supervisord|
    after "deploy:#{deploy}", "supervisord:#{supervisord}"
  end

end
