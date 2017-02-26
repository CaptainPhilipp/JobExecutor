require "redis"

module Helper
  def get_full_queue_key(queue) : String
    "#{Config::APP_NAME}:#{Config::ENV}:#{queue}:queue"
  end
end
