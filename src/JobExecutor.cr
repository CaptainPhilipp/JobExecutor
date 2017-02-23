require "./JobExecutor/*"
require "redis"

module JobExecutor
  redis = Redis.new
  seeker = RedisSeeker.new(redis, "default_scan")
end
