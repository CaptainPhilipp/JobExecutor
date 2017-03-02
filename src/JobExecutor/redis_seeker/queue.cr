require "./helpers/*"

module JobExecutor
  module RedisSeeker

    # Run fibers for each queue
    class Queue
      include RedisSeeker::Helper

      @finded_job : String?

      def initialize : Void
        @queue_keys = Hash(String, String).new
        STANDART_QUEUES.each do |queue|
          @queue_keys[queue] = get_full_queue_key(queue)

          spawn { config_queue_machine(queue).event(:run) }
        end
      end

      def config_queue_machine(queue : String) : StateMachine
        machine = StateMachine.new(:stop)
        machine.when :run,              { stop: :awake_watch }
        machine.when :job_finded,       { lazy_watch: :do_job, awake_watch: :do_job }
        machine.when :job_done,         { do_job: :awake_watch }
        machine.when :too_long_waiting, { awake_watch: :lazy_watch }

        machine.on :lazy_watch do
          print "\n Lazy watch: every #{LAZY_INTERVAL} sec" if PRINT_QUEUER # так веселее.
          loop do
            look_for_a_job(queue) && machine.event(:job_finded)
            sleep LAZY_INTERVAL
          end
        end

        machine.on :do_job do
          print "\n   Do job: #{@finded_job}" if PRINT_QUEUER # так веселее.
          Scan::JobController.new(@finded_job.as String)
            .run

          @finded_job = nil
          machine.event(:job_done)
        end

        machine.on :awake_watch do
          start = Time.now
          print "\n Awake watch: every #{AWAKE_INTERVAL} sec" if PRINT_QUEUER # так веселее.
          loop do
            look_for_a_job(queue) && machine.event(:job_finded)
            time_over?(start) && machine.event(:too_long_waiting)
            sleep AWAKE_INTERVAL
          end
        end
        machine
      end

      def look_for_a_job(queue) : Bool
        result = REDIS.lpop(@queue_keys[queue])
        if result
          @finded_job = result
          true
        else
          false
        end
      end

      def time_over?(start_time) : Bool
        Time.now.epoch - start_time.epoch >= AWAKE_TIME_LIMIT
      end

    end

  end

end
