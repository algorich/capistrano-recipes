namespace :nginx do
  desc "Install latest stable release of nginx"
  task :install, roles: :web do
    if webserver == :unicorn
      run "#{sudo} add-apt-repository -y ppa:nginx/stable"
      run "#{sudo} apt-get -y update"
      run "#{sudo} apt-get -y install nginx"
    elsif webserver == :passenger
      run "#{sudo} apt-key adv --keyserver keyserver.ubuntu.com --recv-keys 561F9B9CAC40B2F7"
      run "#{sudo} apt-get install apt-transport-https ca-certificates -y"
      run "#{sudo} touch /etc/apt/sources.list.d/passenger.list"
      run "#{sudo} sh -c 'echo deb https://oss-binaries.phusionpassenger.com/apt/passenger trusty main > /etc/apt/sources.list.d/passenger.list'"
      run "#{sudo} apt-get update"
      run "#{sudo} apt-get install nginx-extras passenger -y"
      reload
    end
  end
  after "deploy:install", "nginx:install"

  desc "Setup nginx configuration for this application"
  task :setup, roles: :web do
    template 'nginx.erb', '/tmp/nginx_conf'

    run "#{sudo} mv /tmp/nginx_conf /etc/nginx/sites-available/#{application}"
    run "#{sudo} ln -sf /etc/nginx/sites-available/#{application} /etc/nginx/sites-enabled/#{application}"
    run "#{sudo} rm -f /etc/nginx/sites-enabled/default"
    # uncomment passenger_root line in nginx_conf
    run "#{sudo} sed -i '/.*#.*passenger_root.*/ s/# *//' /etc/nginx/nginx.conf" if webserver == :passenger
    run "#{sudo} sed '/.*#.*server_tokens.*/ s/# *//' /etc/nginx/nginx.conf"

    reload
  end
  after "deploy:setup", "nginx:setup"

  %w[start stop restart reload].each do |command|
    desc "#{command} nginx"
    task command, roles: :web do
      run "#{sudo} service nginx #{command}"
    end
  end
end

# NOTE: I found it necessary to manually fix the init script as shown here
# https://bugs.launchpad.net/nginx/+bug/1033856
