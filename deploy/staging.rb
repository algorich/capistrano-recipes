set :rails_env, 'staging'
set :server_name, 'dev.domain.com'
server server_name, :web, :app, :db, primary: true
set :branch, 'develop'
