set_default(:postgresql_host, 'localhost')
set_default(:postgresql_user) { application }
set_default(:postgresql_password) { Capistrano::CLI.password_prompt 'PostgreSQL Password: ' }
set_default(:postgresql_database) { "#{application}_#{rails_env}" }
set_default(:postgresql_pid) { '/var/run/postgresql/9.2-main.pid' }

namespace :postgresql do
  desc 'Install the latest stable release of PostgreSQL.'
  task :install, roles: :db, only: {primary: true} do
    run %Q(echo "deb http://apt.postgresql.org/pub/repos/apt/ $(lsb_release -c | cut -f 2)-pgdg main" | #{sudo} tee /etc/apt/sources.list.d/pgdg.list)
    run "#{sudo} apt-get install -y wget ca-certificates"
    run "wget --quiet -O - https://www.postgresql.org/media/keys/ACCC4CF8.asc | #{sudo} apt-key add -"
    run "#{sudo} apt-get -y update"
    run "#{sudo} apt-get -y install postgresql postgresql-contrib libpq-dev"
  end
  after 'deploy:install', 'postgresql:install'

  desc 'Create a database for this application.'
  task :create_database, roles: :db, only: {primary: true} do
    run %Q{#{sudo} -u postgres psql -c "create user #{postgresql_user} with password '#{postgresql_password}';"}
    run %Q{#{sudo} -u postgres psql -c "create database #{postgresql_database} owner #{postgresql_user};"}
  end
  after 'deploy:setup', 'postgresql:create_database'

  desc 'Generate the database.yml configuration file.'
  task :setup, roles: :app do
    run "mkdir -p #{shared_path}/config"
    template "postgresql.yml.erb", "#{shared_path}/config/database.yml"
  end
  after 'deploy:setup', 'postgresql:setup'

  desc 'Symlink the database.yml file into latest release'
  task :symlink, roles: :app do
    run "ln -nfs #{shared_path}/config/database.yml #{release_path}/config/database.yml"
  end
  after 'deploy:finalize_update', 'postgresql:symlink'

  desc 'Backup the database and download the script'
  task :backup, :roles => :db do
    filename = "#{Time.now.utc.strftime('%Y%m%d%H%M%S')}_#{postgresql_database}"
    sql_filename = "#{filename}.sql"
    tar_filename = "#{filename}.tar.gz"
    run "cd #{current_path}; pg_dump -U#{postgresql_user} -h localhost #{postgresql_database} -f #{sql_filename}" do |ch, stream, out|
      ch.send_data "#{postgresql_password}\n" if out =~ /^Password:/
      puts out
    end
    run "cd #{current_path}; tar -cvzpf #{tar_filename} #{sql_filename}"
    get "#{current_path}/#{tar_filename}", "#{tar_filename}"
  end
end
