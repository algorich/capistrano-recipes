set_default(:mysql_host, 'localhost')
set_default(:mysql_version) { '5.1' }
set_default(:mysql_user) { application } # max 16 chars
set_default(:mysql_root_password) { Capistrano::CLI.password_prompt 'Mysql Root Password: ' }
set_default(:mysql_app_password) { Capistrano::CLI.password_prompt 'Mysql App Password: ' }
set_default(:mysql_database) { "#{application.gsub('-', '_')}_#{rails_env}" }
set_default(:mysql_pid) { '/var/run/mysqld/mysqld.pid' }
set_default(:mysql_socket) { '/var/run/mysqld/mysqld.sock' }

namespace :mysql do
  desc 'Install the latest stable release of mysql.'
  task :install, roles: :db, only: {primary: true} do
    # About this lines for set passwords http://askubuntu.com/a/79881
    run "echo mysql-server mysql-server/root_password password #{mysql_root_password} | #{sudo} debconf-set-selections"
    run "echo mysql-server mysql-server/root_password_again password #{mysql_root_password} | #{sudo} debconf-set-selections"
    run "#{sudo} apt-get install -y libmysqlclient-dev mysql-server mysql-client"
  end
  after 'deploy:install', 'mysql:install'

  desc 'Create a database for this application.'
  task :create_database, roles: :db, only: {primary: true} do
    run %Q{#{sudo} mysql -u root -p#{mysql_root_password} mysql -e "CREATE DATABASE #{mysql_database};"}
    run %Q{#{sudo} mysql -u root -p#{mysql_root_password} mysql -e "CREATE USER '#{mysql_user}'@'#{mysql_host}' IDENTIFIED BY '#{mysql_app_password}';"}
    run %Q{#{sudo} mysql -u root -p#{mysql_root_password} mysql -e "GRANT ALL ON #{mysql_database}.* TO '#{mysql_user}'@'#{mysql_host}';"}
  end
  after 'deploy:setup', 'mysql:create_database'

  desc 'Generate the database.yml configuration file.'
  task :setup, roles: :app do
    run "mkdir -p #{shared_path}/config"
    template "mysql.yml.erb", "#{shared_path}/config/database.yml"
  end
  after 'deploy:setup', 'mysql:setup'

  desc 'Symlink the database.yml file into latest release'
  task :symlink, roles: :app do
    run "ln -nfs #{shared_path}/config/database.yml #{release_path}/config/database.yml"
  end
  after 'deploy:finalize_update', 'mysql:symlink'
end
