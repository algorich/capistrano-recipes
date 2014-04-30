require 'bundler/capistrano'
require 'capistrano/ext/multistage'

set :database, 'mysql'
set :unicorn_workers, 2
set :user_ssl, false

set :backup, true
set :backup_host, 'ci.algorich.com.br'
set :backup_port, '22'
set :backup_user, 'root'
set :backup_time, '12:00am'

set :log_rotate, true
set :log_rotate_type, 'time' # can be either 'size' or 'time'
set :log_rotate_value, 'daily'
set :log_rotate_keep, 7

set :use_delayed_job, true

load 'config/recipes/base'
load 'config/recipes/nginx'
load 'config/recipes/unicorn'
load "config/recipes/#{database}"
load 'config/recipes/nodejs'
load 'config/recipes/rbenv'
load 'config/recipes/check'
load 'config/recipes/delayed_job' if use_delayed_job
load 'config/recipes/monit'
load 'config/recipes/ufw'
load 'config/recipes/fail2ban'
load 'config/recipes/supervisord'
load 'config/recipes/backup' if backup
load 'config/recipes/log_rotate' if log_rotate
load 'config/recipes/project_dependencies'
load 'config/recipes/info' # this should be the last recipe to be loaded

set :stages, %w(production staging)

set :application, 'application name'
set :user, 'deploy'
set :deploy_to, "/home/#{user}/apps/#{application}"
set :deploy_via, :remote_cache
set :use_sudo, false

set :scm, 'git'
set :repository, "git@gitlab.com:algorich/#{application}.git"

set :maintenance_template_path, File.expand_path('../recipes/templates/maintenance.html.erb', __FILE__)

default_run_options[:pty] = true
ssh_options[:forward_agent] = true

after 'deploy', 'deploy:cleanup' # keep only the last 5 releases
