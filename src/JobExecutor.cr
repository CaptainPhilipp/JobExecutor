require "./JobExecutor/*"
require "redis"

module JobExecutor
  redis  = Redis.new
  seeker = RedisQueueSeeker.new(redis, "default_scan") # runs fiber
  sleep
end
