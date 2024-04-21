# config valid for current version and patch releases of Capistrano
lock "~> 3.18.1"

server '54.188.245.219', user: 'deploy', roles: %w{app db web}, port: 2222
set :application, "capt"
set :branch, 'main'
set :repo_url, "git@github.com:bparanj/capt.git"
set :deploy_to, '/home/deploy/apps/capt'
set :linked_files, fetch(:linked_files, []).push('config/database.yml', 'config/master.key')
set :linked_dirs, fetch(:linked_dirs, []).push('log', 'tmp/pids', 'tmp/cache', 'tmp/sockets', 'public/system', 'public/uploads')
set :keep_releases, 5

set :default_env, {
  'CAPT_DATABASE_PASSWORD' => ENV['CAPT_DATABASE_PASSWORD']
}

namespace :deploy do
  namespace :check do
    before :linked_files, :upload_config_files do
      on roles(:app), in: :sequence, wait: 10 do
        # Upload master.key
        unless test("[ -f #{shared_path}/config/master.key ]")
          upload! 'config/master.key', "#{shared_path}/config/master.key"
        end

        # Upload database.yml
        unless test("[ -f #{shared_path}/config/database.yml ]")
          upload! 'config/database.yml', "#{shared_path}/config/database.yml"
        end
      end
    end
  end
end

namespace :deploy do
  desc 'Create database if it does not exist'
  task :create_db do
    on roles(:db) do
      within release_path do
        with rails_env: fetch(:rails_env) do
          execute :rails, 'db:create'
        end
      end
    end
  end

  desc 'Runs rake db:migrate if migrations are pending'
  task :migrate do
    on primary :db do
      within release_path do
        with rails_env: fetch(:rails_env) do
          execute :rails, 'db:migrate'
        end
      end
    end
  end

  before 'deploy:migrate', 'deploy:create_db'
end

# Capistrano task to print environment variables
namespace :deploy do
  desc 'Print environment variables'
  task :print_env do
    on roles(:app), in: :sequence, wait: 5 do
      execute :printenv
    end
  end

  after 'deploy:published', 'deploy:print_env'
end


# Default branch is :master
# ask :branch, `git rev-parse --abbrev-ref HEAD`.chomp

# Default deploy_to directory is /var/www/my_app_name
# set :deploy_to, "/var/www/my_app_name"

# Default value for :format is :airbrussh.
# set :format, :airbrussh

# You can configure the Airbrussh format using :format_options.
# These are the defaults.
# set :format_options, command_output: true, log_file: "log/capistrano.log", color: :auto, truncate: :auto

# Default value for :pty is false
# set :pty, true

# Default value for :linked_files is []
# append :linked_files, "config/database.yml", 'config/master.key'

# Default value for linked_dirs is []
# append :linked_dirs, "log", "tmp/pids", "tmp/cache", "tmp/sockets", "public/system", "vendor", "storage"

# Default value for default_env is {}
# set :default_env, { path: "/opt/ruby/bin:$PATH" }

# Default value for local_user is ENV['USER']
# set :local_user, -> { `git config user.name`.chomp }

# Default value for keep_releases is 5
# set :keep_releases, 5

# Uncomment the following to require manually verifying the host key before first deploy.
# set :ssh_options, verify_host_key: :secure
