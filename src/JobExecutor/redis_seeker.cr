require "state_machine"
require "json"

module JobExecutor

  class RedisSeeker
    getter :redis, :queue

    @finded_job : String?

    def initialize(@redis : Redis, queue : String | Symbol) : Void
      @queue = map_queue(queue).as String
      watch_queue
    end

    def watch_queue : Void
      puts "\nRUN " + @queue
      m = StateMachine.new(:stop)
      m.when :start, { stop: :lazy_watch }
      m.when :job_finded, { lazy_watch: :do_job, awake_watch: :do_job }
      m.when :job_done,   { do_job: :awake_watch }
      m.when :too_long_waiting, { awake_watch: :lazy_watch }

      m.on :lazy_watch do
        loop do
          print ":"
          look_for_a_job && m.trigger!(:job_finded)
          sleep Config::LAZY_INTERVAL
        end
      end

      m.on :do_job do
        specification = JSON.parse @finded_job.as(String)
        #
        # TODO run job
        #
        m.trigger!(:job_done)
      end

      m.on :awake_watch do
        start = Time.now
        loop do
          print "."
          look_for_a_job    && m.trigger!(:job_finded)
          time_over?(start) && m.trigger!(:too_long_waiting)
          sleep Config::AWAKE_INTERVAL
        end
      end
      m.events
      m.trigger :start
    end

    def look_for_a_job : Bool
      key = @queue
      @finded_job = redis.lpop(key)
      !@finded_job.nil?
    end

    def time_over?(start_time) : Bool
      Time.now.epoch - start_time.epoch >= Config::AWAKE_TIME_LIMIT
    end

    def map_queue(queue) : String
      "#{Config::APP_NAME}:#{Config::ENV}:#{queue}:queue"
    end

  end

end
