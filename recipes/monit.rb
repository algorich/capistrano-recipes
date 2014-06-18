set_default(:monit_pem, '/etc/monit/monit.pem')
set_default(:monit_password) { Capistrano::CLI.password_prompt 'Monit Interface Password: ' }

namespace :monit do
  desc 'Install Monit'
  task :install do
    run "#{sudo} apt-get -y install monit"
  end
  after 'deploy:install', 'monit:install'

  desc 'Setup all Monit configuration'
  task :setup do
    monit_config 'monitrc', destination: '/etc/monit/monitrc'
    nginx
    eval(database)
    unicorn
    syntax
    reload
    delayed_job if use_delayed_job
  end
  after 'deploy:setup', 'monit:setup'

  task(:nginx, roles: :web) { monit_config 'nginx' }
  task(database.to_sym, roles: :db) { monit_config database }
  task(:unicorn, roles: :app) { monit_config 'unicorn', multiple: true }

  task(:delayed_job, roles: :web) do
    monit_config 'delayed_job', multiple: true
    template 'delayed_job_init.erb', '/tmp/delayed_job'
    run 'chmod +x /tmp/delayed_job'
    run "#{sudo} mv /tmp/delayed_job /etc/init.d/delayed_job_#{application}"
  end

  %w[start stop restart syntax reload].each do |command|
    desc "Run Monit #{command} script"
    task command do
      run "#{sudo} service monit #{command}"
    end
  end
end

def monit_config(name, opts = {})
  opts = { destination: nil, multiple: false}.merge(opts)

  dest_name = opts[:multiple] ? "#{name}_#{application}.conf" ? name
  opts[:destination] ||= "/etc/monit/conf.d/#{dest_name}.conf"

  template "monit/#{name}.erb", "/tmp/monit_#{name}"
  run "#{sudo} mv /tmp/monit_#{name} #{opts[:destination]}"
  run "#{sudo} chown root #{opts[:destination]}"
  run "#{sudo} chmod 600 #{opts[:destination]}"
end
