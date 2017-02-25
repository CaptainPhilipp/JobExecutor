require "state_machine"
require "json"

module JobExecutor
  
  # Run fibers for each queue
  class RedisQueueSeeker
    include Helper
    getter :redis, :queue

    @finded_job : String?

    def initialize(@redis : Redis, *queues : String | Symbol) : Void
      @queues = Hash(String, String).new
      queues.each do |queue|
        @queues[queue] = queue_name_to_full_key(queue)

        spawn { queue_machine(queue).trigger(:run) }
      end
    end

    def queue_machine(queue : String) : StateMachine
      machine = StateMachine.new(:stop)
      machine.when :run, { stop: :lazy_watch }
      machine.when :job_finded, { lazy_watch: :do_job, awake_watch: :do_job }
      machine.when :job_done,   { do_job: :awake_watch }
      machine.when :too_long_waiting, { awake_watch: :lazy_watch }

      machine.on :lazy_watch do
        loop do
            print ":" # так веселее.
          look_for_a_job(queue) && machine.trigger!(:job_finded)
          sleep Config::LAZY_INTERVAL
        end
      end

      machine.on :do_job do
        specification = JSON.parse @finded_job.as(String)
        #
        # TODO run job
        #
        machine.trigger!(:job_done)
      end

      machine.on :awake_watch do
        start = Time.now
        loop do
            print "." # так веселее.
          look_for_a_job(queue) && machine.trigger!(:job_finded)
          time_over?(start) && machine.trigger!(:too_long_waiting)
          sleep Config::AWAKE_INTERVAL
        end
      end
      machine
    end

    def look_for_a_job(queue) : Bool
      @finded_job = redis.lpop(@queues[queue])
      !@finded_job.nil?
    end

    def time_over?(start_time) : Bool
      Time.now.epoch - start_time.epoch >= Config::AWAKE_TIME_LIMIT
    end

  end

end
