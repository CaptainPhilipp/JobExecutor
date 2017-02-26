module JobExecutor

  # Run fibers for each queue
  class RedisQueueSeeker
    include Helper
    getter :redis, :queue

    @finded_job : String?

    def initialize(@redis : Redis) : Void
      @queue_keys = Hash(String, String).new
      Config::STANDART_QUEUES.each do |queue|
        @queue_keys[queue] = get_full_queue_key(queue)

        spawn { config_queue_machine(queue).event(:run) }
      end
    end

    def config_queue_machine(queue : String) : StateMachine
      machine = StateMachine.new(:stop)
      machine.when :run,              { stop: :lazy_watch }
      machine.when :job_finded,       { lazy_watch: :do_job, awake_watch: :do_job }
      machine.when :job_done,         { do_job: :awake_watch }
      machine.when :too_long_waiting, { awake_watch: :lazy_watch }

      machine.on :lazy_watch do
        loop do
            print ":" # так веселее.
          look_for_a_job(queue) && machine.event(:job_finded)
          sleep Config::LAZY_INTERVAL
        end
      end

      machine.on :do_job do
        specification = JSON.parse @finded_job.as(String)
        #
        # TODO run job
        #
        machine.event(:job_done)
      end

      machine.on :awake_watch do
        start = Time.now
        loop do
            print "-" # так веселее.
          look_for_a_job(queue) && machine.event(:job_finded)
          time_over?(start) && machine.event(:too_long_waiting)
          sleep Config::AWAKE_INTERVAL
        end
      end
      machine
    end

    def look_for_a_job(queue) : Bool
      result = redis.lpop(@queue_keys[queue])
      if result
        @finded_job = result
        true
      else
        false
      end
    end

    def time_over?(start_time) : Bool
      Time.now.epoch - start_time.epoch >= Config::AWAKE_TIME_LIMIT
    end

  end

end
