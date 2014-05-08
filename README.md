# Deploy with capistrano

These configurations depends on capistrano. It deploy to a staging and a
production environment. It uses:

1. **nginx** with **unicorn** (2 workers, configurable)
2. **unicornherder**, monitored by **supervisord** (runing
   its web interface at port 9001), to manage the unicorn instances
3. **delayed_job** to run background processing, if the `use_delayed_job`
   flag is set in `deploy.rb`.
4. **monit** (running its web interface at port 2812) to manage
   the database (**mysql** or **postgres**, configurable), nginx
   and to watch for the resource usage of unicorn instances and
   all the previous services. Check each file under `recipes/templates/monit`
   for the resource limit of the services.
5. **whenever** and **backup** gems to backup the database, user uploaded files,
   and logs. If the flag `backup` is set on `deploy.rb`. The script will do daily
   backups of the database and keep one week of dailies, one month of weeklies,
   and a year of monthlies. The uploaded files will be kept synced through RSync.
   Please, take a look at the backup model templates and customize them to match
   your needs if the options in `deploy.rb` aren't enough, the **backup**
   gem is too complete and full of tools for us to parameterize everything in
   there. You can find its docs [here](http://meskyanichi.github.io/backup/v4).
6. **logrotate** to rotate the logs, either by size or time, if `rotate_log` is
   set in `deploy.rb`. Size AND time conditions are yet not supported, because
   logrotate 3.81 is still not present in most Linux distributions.
7. installs **paperclip-optimizer** dependencies if the flag is set in
   `deploy.rb`.

## Recomentadations

Before deploy to production, use the following gems:

1. [brakeman](http://brakemanscanner.org): To mitigate the security problems

2. [rack-mini-profiler](https://github.com/MiniProfiler/rack-mini-profiler): To mitigate database performance issues

3. [simplecov](https://github.com/colszowka/simplecov): To mitigate missing tests

4. [exception_notification](http://smartinez87.github.io/exception_notification/): To warning about live errors on production


## Configuring the VPS

After create the VPS, **with a ssh key exclusive for the projet (see below),**
you must follow this steps.

### Create a ssh key

``` bash
cd ~/.ssh
ssh-keygen -t rsa -C '<me@mail.com>'
```

### Set the locale

If you have some locale error like:

``` text
 locale: Cannot set LC_ALL to default locale: No such file or directory
 ```

Run:

``` bash
echo "pt_BR.UTF-8 UTF-8" >> /var/lib/locales/supported.d/local && dpkg-reconfigure locales
```

### Update the server

``` bash
apt-get -y update && apt-get -y upgrade
```

### Create staging environment

Create the staging environment. Just run the command above and make the
necessary modifications for staging environment:

``` bash
cp config/environments/production.rb config/environments/staging.rb
```

### Add the deploy user

On the server:

``` bash
adduser deploy --ingroup sudo
```

Get the [password here](http://migre.me/gx4Uz)

On your machine run:

``` bash
ssh-copy-id -i ~/.ssh/id_rsa_<project>.pub deploy@<server>
```

### Permit ssh to gitlab

Logged in as deploy user, run:

``` bash
ssh git@gitlab.com
```

### Change capistrano configs

Add to your Gemfile (updating the versions):

``` ruby
gem 'unicorn', '~> 4.7.0'

group :development do
  gem 'capistrano', '~> 2.15.5', require: false
end
```

Run `bundle install` then run `capify .`.

Uncomment the line `load 'deploy/assets'` on the `Capfile`. Then copy all files
of this project to *config* dir, except the *Capfile*, that should be copied to
the rails root path.

Remember to choose a database (mysql or postgresql) and set wether you use SSL
or not in the `deploy.rb` file and all the other project specific settings in
there.

### Project dependencies

Ajust the recipe project_dependencies for your project needs

### Install

Before install, you must check if your new ssh-key is added:

``` bash
ssh-add -L
```

If you don't see your key, you can add typing the following command:

``` bash
ssh-add <path_to_key>
```

Then, you are able to install:

``` bash
cap <environment> deploy:install
```

### Capistrano setup

``` bash
cap <environment> deploy:setup
```

### First deploy

``` bash
cap <environment> deploy:cold
```

### If need to send mail

``` bash
sudo apt-get install sendmail
```

### Finally

After that, just run `cap <environment> deploy`.
