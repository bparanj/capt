class Health
  def self.database
    ActiveRecord::Base.connected?
  end

  def self.redis
    Redis.current.ping == "PONG"
  rescue StandardError
    false
  end
end

