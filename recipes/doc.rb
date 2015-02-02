require 'base64'

namespace :doc do
  set_default(:doc_user) { Capistrano::CLI.password_prompt 'Doc access User: ' }
  set_default(:doc_password) { Capistrano::CLI.password_prompt 'Doc access Encypted Password: ' }

  desc 'Setup app documentation configuration'
  task :setup, roles: :web do
    # The prepend "1" on the file name is a tiny hack to nginx load this file
    # first. This is done to avoid an ssl error when it is turned 'on' at a
    # prior loaded file by nginx.
    file_name = "1#{application}_doc"

    encoded_password = doc_password.crypt(
      Base64.encode64(Digest::SHA1.digest(doc_password))
    )

    template 'nginx_doc.erb', '/tmp/nginx_doc'
    run %Q(#{sudo} mv /tmp/nginx_doc /etc/nginx/sites-available/#{file_name})
    run %Q(#{sudo} ln -sf /etc/nginx/sites-available/#{file_name} /etc/nginx/sites-enabled/#{file_name})
    run %Q(echo "#{doc_user}:#{encoded_password}" | #{sudo} tee /etc/nginx/.htpasswd > /dev/null)
    run %Q(#{sudo} chmod 644 /etc/nginx/.htpasswd)
  end
  after 'deploy:setup', 'doc:setup'
  after 'doc:setup', 'nginx:reload'

  desc 'Generate app documentation'
  task :generate, roles: :app do
    run %Q(cd #{latest_release} && bundle exec yard doc --quiet)
    run "ln -sf #{latest_release}/doc #{shared_path}/doc"
  end
  after 'deploy:finalize_update', 'doc:generate'

end
