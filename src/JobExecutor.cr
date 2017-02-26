require "./JobExecutor/*"

module JobExecutor
  redis  = Redis.new
  seeker = RedisQueueSeeker.new(redis) # runs fiber

  loop do
    puts "exit? y/n"
    break if gets == "y"
  end
end
