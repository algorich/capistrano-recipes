namespace :info do
  desc "Iformation about what have to be done after automatic setup is done"
  task :setup, roles: :web do
    Capistrano::CLI.password_prompt(
      %q{
      ATENTION!!!

      1) You must run `sudo ufw enable` to enable the firewall!"

      2) Enable automatic security updates:

        `sudo apt-get install unattended-upgrades bsd-mailx`
        `sudo dpkg-reconfigure -plow unattended-upgrades`

        Answer 'yes'

        Uncomment and edit the option "Unattended-Upgrade::Mail" on file
        /etc/apt/apt.conf.d/50unattended-upgrades

        visit for more info: http://migre.me/guOm0

      3) Ajust some configuration for fail2ban

      Edit the option "destemail" on file /etc/fail2ban/jail.local

      Run `sudo service fail2ban restart`

      4) Ajust the nginx config

      If you have a www redirect or will use https, uncomment the pertinent
      lines nginx congif file.


      (press any key to continue)})
  end
  after "deploy:setup", "info:setup"
end