require "redis"
require "state_machine"
require "json"

REDIS = Redis.new

require "./redis_seeker/*"
