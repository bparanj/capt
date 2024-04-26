class Health
  def self.database
    ActiveRecord::Base.connection.active?
  end

  def self.redis
    Redis.new.ping == "PONG"

  rescue StandardError
    false
  end
end
