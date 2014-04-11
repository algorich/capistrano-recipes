def template(from, to)
  erb = File.read(File.expand_path("../templates/#{from}", __FILE__))
  put ERB.new(erb).result(binding), to
end

def set_default(name, *args, &block)
  set(name, *args, &block) unless exists?(name)
end

namespace :deploy do
  desc 'Install everything into the server'
  task :install do
    run "#{sudo} apt-get -y install git-core python-software-properties vim htop"
  end

  desc 'Run database migrations'
  task :migrate do
    run %Q{cd #{latest_release} && #{rake} RAILS_ENV=#{rails_env} db:migrate}
  end
  after "#{database}:symlink", 'deploy:migrate'

  namespace :assets do

    desc 'Remove the assets manifest'
    task :remove_manifest, :roles => :web, :except => { :no_release => true } do
      run %Q{cd #{latest_release} && rm public/assets/manifest-* }
    end
    before 'deploy:assets:update_asset_mtimes', 'deploy:assets:remove_manifest'

    desc 'Run the precompile task locally and rsync with shared'
    task :precompile, :roles => :web, :except => { :no_release => true } do
      from = source.next_revision(current_revision)
      if releases.length <= 1 || capture("cd #{latest_release} && #{source.local.log(from)} vendor/assets/ app/assets/ | wc -l").to_i > 0
        %x{RAILS_ENV=#{rails_env} bundle exec rake assets:precompile}
        %x{rsync --recursive --times --rsh=ssh --compress --human-readable --progress public/assets #{user}@#{server_name}:#{shared_path}}
        %x{bundle exec rake assets:clobber}
      else
        logger.info 'Skipping asset pre-compilation because there were no asset changes'
      end
    end
  end
end
