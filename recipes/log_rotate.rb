namespace :log do
  namespace :rotate do
    desc 'Setup the app log rotation'
    task :setup, roles: :web do
      template 'log_rotate.erb', '/tmp/log_rotate'
      run "#{sudo} mv /tmp/log_rotate /etc/logrotate.d/log_rotate_#{ application }"
    end
  end
end
after "deploy:setup", "log:rotate:setup"
