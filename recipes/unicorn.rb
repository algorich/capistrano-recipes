set_default(:unicorn_user) { user }
set_default(:unicorn_pid) { "#{current_path}/tmp/pids/unicorn.pid" }
set_default(:unicorn_config) { "#{shared_path}/config/unicorn.rb" }
set_default(:unicorn_log) { "#{shared_path}/log/unicorn.log" }

# this is done on deploy.rb file
# set_default(:unicorn_workers, 2)

namespace :unicorn do
  desc 'Setup Unicorn initializer and app configuration'
  task :setup, roles: :app do
    run "mkdir -p #{shared_path}/config"
    template "unicorn.rb.erb", unicorn_config
  end
  after 'deploy:setup', 'unicorn:setup'
end
