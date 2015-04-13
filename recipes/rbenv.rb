set_default :ruby_version, '2.2.1'

namespace :rbenv do
  desc 'Install rbenv, Ruby, and the Bundler gem'
  task :install, roles: :app do
    # install and init rbenv
    run 'git clone https://github.com/sstephenson/rbenv.git ~/.rbenv'
    bashrc = <<-BASHRC
if [ -d $HOME/.rbenv ]; then
  export PATH="$HOME/.rbenv/bin:$PATH"
  eval "$(rbenv init -)"
fi
BASHRC
    put bashrc, '/tmp/rbenvrc'
    run 'cat /tmp/rbenvrc ~/.bashrc > ~/.bashrc.tmp'
    run 'mv ~/.bashrc.tmp ~/.bashrc'
    run %q{export PATH="$HOME/.rbenv/bin:$PATH"}
    run %q{eval "$(rbenv init -)"}
    run 'git clone https://github.com/sstephenson/ruby-build.git ~/.rbenv/plugins/ruby-build'
    # Ruby dependencies. More info: https://github.com/sstephenson/ruby-build/wiki
    run "#{sudo} apt-get -y install build-essential autoconf libssl-dev libyaml-dev libreadline6 libreadline6-dev zlib1g zlib1g-dev"

    run "rbenv install #{ruby_version}"
    run "rbenv global #{ruby_version}"
    run 'gem install bundler --no-ri --no-rdoc'
    run 'rbenv rehash'
  end
  after 'deploy:install', 'rbenv:install'
end
