require "./JobExecutor/*"

module JobExecutor
  RedisSeeker::Queue.new # runs fiber

  print "\n    PRESS ENTER TO EXIT\n\n"
  gets
end
