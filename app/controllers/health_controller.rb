# app/controllers/health_controller.rb
class HealthController < ApplicationController
  def index 
    database_status = Health.database ? 'OK' : 'FAILED'
    redis_status = Health.redis ? 'OK' : 'FAILED'

    render json: { database: database_status, redis: redis_status }
  end
end

