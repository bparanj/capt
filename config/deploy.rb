# config valid for current version and patch releases of Capistrano
lock "~> 3.18.1"

server '54.188.245.219', user: 'deploy', roles: %w{app db web}, port: 2222
set :application, "capt"
# Default branch is :master
set :branch, 'main'
set :repo_url, "git@github.com:bparanj/capt.git"
# Default deploy_to directory is /var/www/my_app_name
set :deploy_to, '/home/deploy/apps/capt'
set :linked_files, fetch(:linked_files, []).push('config/database.yml', 'config/master.key')
# append :linked_dirs, "log", "tmp/pids", "tmp/cache", "tmp/sockets", "public/system", "vendor", "storage"
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

set :ssh_options, {
  keys: %w(~/.ssh/id_ed25519), # Ensure this path is correct
  forward_agent: true,
  auth_methods: %w(publickey)
}
