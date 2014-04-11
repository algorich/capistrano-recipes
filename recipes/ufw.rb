# ufw is a front-end to iptables

namespace :ufw do
  desc "Install ufw"
  task :install, roles: :web do
    run "#{sudo} apt-get -y install ufw"
  end
  after "deploy:install", "ufw:install"

  desc "Setup ufw configuration for this application"
  task :setup, roles: :web do
    run "#{sudo} ufw default deny incoming" # deny all incomming
    run "#{sudo} ufw default allow outgoing" # allow all outgoing
    run "#{sudo} ufw allow 22/tcp" # allow ssh
    run "#{sudo} ufw allow 80/tcp" # allow www
    run "#{sudo} ufw allow 443/tcp" # allow www via https
    run "#{sudo} ufw allow 2812/tcp" # allow monit web inteface
  end
  after "deploy:setup", "ufw:setup"
end

# reference: http://migre.me/gtNNa