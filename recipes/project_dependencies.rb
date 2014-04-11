namespace :project_dependencies do
  desc 'Install project dependencies'
  task :install, roles: :web do
    # nokogiri dependencies
    #run "#{sudo} apt-get -y install libxslt-dev libxml2-dev"
    # paperclip dependencie
    #run "#{sudo} apt-get -y install imagemagick"
    # sendmail
    #run "#{sudo} apt-get -y install sendmail"
  end
  after 'deploy:install', 'project_dependencies:install'
end