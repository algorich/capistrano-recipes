namespace :project_dependencies do
  desc 'Install project dependencies'
  task :install, roles: :web do
    # nokogiri dependencies
    run "#{sudo} apt-get -y install libxslt-dev libxml2-dev"

    # paperclip dependencies
    run "#{sudo} apt-get -y install imagemagick"

    # paperclip-optimizer
    if paperclip_optimizer
      run "#{sudo} apt-get install -y advancecomp gifsicle jhead jpegoptim libjpeg-progs optipng pngcrush"
      run "#{sudo} npm install -g svgo"
    end
  end
  after 'deploy:install', 'project_dependencies:install'
end
