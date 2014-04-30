namespace :backup do
  desc "Install backup gem"
  task :install, roles: [:web, :db] do
    run "gem install backup --no-ri --no-rdoc"
    run "gem install whenever --no-ri --no-rdoc"
  end
  after "deploy:install", "backup:install"

  desc "Setup a template file for database backup"
  task :setup, roles: [:db] do
    template 'backup_files.rb.erb', '/tmp/backup_files.rb'
    template 'backup_database.rb.erb', '/tmp/backup_database.rb'
    template 'backup_config.rb.erb', '/tmp/backup_config.rb'
    template 'backup_schedule.rb.erb', '/tmp/backup_schedule.rb'
    run "mkdir -p #{shared_path}/config/backup/"
    run "mkdir -p #{shared_path}/config/backup/.data"
    run "mkdir -p #{shared_path}/config/backup/log"
    run "mkdir -p #{shared_path}/config/backup/models"
    run "mkdir -p #{shared_path}/config/backup/.tmp"

    run "mv /tmp/backup_schedule.rb #{shared_path}/config/backup/backup_schedule.rb"
    run "mv /tmp/backup_database.rb #{shared_path}/config/backup/models/backup_database.rb"
    run "mv /tmp/backup_files.rb #{shared_path}/config/backup/models/backup_files.rb"
    run "mv /tmp/backup_config.rb #{shared_path}/config/backup/config.rb"
    run "ssh #{backup_user}@#{backup_host} -p #{backup_port} -t 'mkdir -p ~/backups'"
  end
  after "deploy:setup", "backup:setup"

  desc "Run all backups"
  task :all do
  end
  after "backup:all", "backup:database", "backup:files"

  desc "Automatically schedule the backup in cron using whenever gem"
  task :schedule do
    run "whenever -f #{shared_path}/config/backup/backup_schedule.rb --update-crontab"
  end

  desc "Run the database backup"
  task :database do
    run "RAILS_ENV=#{rails_env} backup perform --trigger db_backup --root-path #{shared_path}/config/backup"
  end

  desc "Run the files backup"
  task :files do
    run "RAILS_ENV=#{rails_env} backup perform --trigger files_backup --root-path #{shared_path}/config/backup"
  end
end
