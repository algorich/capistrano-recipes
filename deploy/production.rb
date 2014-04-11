set :rails_env, 'production'
set :server_name, 'domain.com'
server server_name, :web, :app, :db, primary: true
set :branch, 'master'
