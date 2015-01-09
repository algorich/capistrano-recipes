set :websocket_rails_pid, -> { "#{shared_path}/pids/websocket_rails.pid" }

namespace :websocket_rails do
  desc "Install latest stable release of Redis"
  task :install_redis, roles: :web do
    run "#{sudo} apt-get install redis-server -y"
    run "#{sudo} service redis-server start"
  end
  after "deploy:install", "websocket_rails:install_redis"

  desc 'Setup websocket_rails start-stop script'
  task :setup, roles: :app do
    template "websocket_rails_server.erb", "#{shared_path}/websocket_rails_server"
    run "#{sudo} chmod +x #{shared_path}/websocket_rails_server"
  end
  after 'deploy:setup', 'websocket_rails:setup'
end
