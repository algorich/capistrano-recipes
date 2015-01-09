namespace :passenger do
  desc 'Restart the app in Passenger'
  task :restart, roles: :app do
    run "touch #{current_path}/tmp/restart.txt"
  end
  after 'deploy:restart', 'passenger:restart'
end
