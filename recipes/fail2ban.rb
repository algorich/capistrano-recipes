namespace :fail2ban do
  desc "Install fail2ban"
  task :install, roles: :web do
    run "#{sudo} apt-get -y install fail2ban"
  end
  after "deploy:install", "fail2ban:install"

  desc "Setup fail2ban configuration for this application"
  task :setup, roles: :web do
    run "#{sudo} cp /etc/fail2ban/jail.conf /etc/fail2ban/jail.local"
  end
  after "deploy:setup", "fail2ban:setup"
end

# reference: http://migre.me/gxXWq