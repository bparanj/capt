require Rails.root.join('app', 'checks', 'database_check')

OkComputer::Registry.register "database", DatabaseCheck.new

