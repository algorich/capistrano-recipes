require 'bundler/capistrano'
require 'capistrano/ext/multistage'

set :database, 'postgresql'
set :unicorn_workers, 2
set :use_ssl, false


set :webserver, :unicorn
set :websocket_rails, true

set :www_redirect, true

# depends of yard gem. see doc recipe.
set :doc, true

set :paperclip_optimizer, true

# backup stuff
set :backup, true
set :backup_host, 'backups.algorich.com.br'
set :backup_port, '22'
set :backup_user, 'foo'
set :backup_time, '12:00am'

set :backup_notification, true
# if backup_notification is false, you can delete all these notification stuff
set :backup_notification_on_success, true
set :backup_notification_on_warning, true
set :backup_notification_on_failure, true

set :notification_mail_from,            'sender@email.com'
set :notification_mail_to,              'receiver@email.com'
set :notification_mail_address,         'smtp.gmail.com'
set :notification_mail_port,            587
set :notification_mail_domain,          'your.host.name'
set :notification_mail_user_name,       'sender@email.com'
set :notification_mail_password,        'my_password'
set :notification_mail_authentication,  'plain'
set :notification_mail_encryption,      :starttls
# end of backup stuff

set :log_rotate, true
set :log_rotate_type, 'time' # can be either 'size' or 'time'
set :log_rotate_value, 'daily'
set :log_rotate_keep, 7
set :backup_logs, true
set :log_backup_keep, 14

set :use_delayed_job, true

set :stages, %w(production staging)

set :application, 'Project Name'

set :user, 'deploy'
set :deploy_to, "/home/#{user}/apps/#{application}"
set :deploy_via, :remote_cache
set :use_sudo, false

set :scm, 'git'
set :repository, "git@bitbucket.org:algorich/#{application}.git"

set :maintenance_template_path, File.expand_path('../recipes/templates/maintenance.html.erb', __FILE__)

default_run_options[:pty] = true
ssh_options[:forward_agent] = true

after 'deploy', 'deploy:cleanup' # keep only the last 5 releases

load 'config/recipes/base'
load 'config/recipes/nginx'
load 'config/recipes/unicorn' if webserver == :unicorn
load 'config/recipes/passenger' if webserver == :passenger
load 'config/recipes/websocket_rails' if websocket_rails
load "config/recipes/#{database}"
load 'config/recipes/nodejs'
load 'config/recipes/rbenv'
load 'config/recipes/check'
load 'config/recipes/delayed_job' if use_delayed_job
load 'config/recipes/monit'
load 'config/recipes/ufw'
load 'config/recipes/fail2ban'
load 'config/recipes/supervisord' if webserver == :unicorn
load 'config/recipes/backup' if backup
load 'config/recipes/log_rotate' if log_rotate
load 'config/recipes/project_dependencies'
load 'config/recipes/doc' if doc
load 'config/recipes/info' # this should be the last recipe to be loaded
