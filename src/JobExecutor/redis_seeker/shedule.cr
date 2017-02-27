require "./helpers/*"

# TODO finish shedule scaning
module JobExecutor
  module RedisSeeker

    # Run fibers for each queue
    class Schedule
      include RedisSeeker::Helper

      @finded_jobs : Array(String)?
      @interval : Int32

      def initialize : Void
        @interval  = SCHEDULE_INTERVAL
        @queue_key = get_full_queue_key(SCHEDULE_QUEUE)

        schedule_machine.trigger(:run)
      end

      def schedule_machine : StateMachine
        machine = StateMachine.new(:stop)
        machine.when :run,          { stop: :look_past }
        machine.when :have_jobs,    { look_past: :do_jobs }
        machine.when :jobs_is_done, { do_jobs: :look_past }
        machine.when :havent_jobs,  { look_past: :look_future }
        machine.when :forthcoming,  { look_future: :look_past }


        machine.on :look_past do
          loop do
            look_for_a_job(upto: Time.now.epoch) && machine.trigger!(:have_jobs)
            sleep @interval
          end
        end

        machine.on :do_jobs do
          @finded_jobs.each do |job|
            specification = JSON.parse @finded_jobs.as(String)
            #
            # TODO run job, set job to next time
            #
          end
          machine.trigger!
        end

        machine.on :look_future do
          now = Time.now.epoch
          finded = get_range(now, now + SCHEDULE_INTERVAL)
          @interval = finded.nil? ? SHEDULE_INTERVAL : SHEDULE_INTERVAL / 10
        end
        machine
      end

      def look_for_a_job(*, from = 0, upto : I_32) : Bool
        if result = get_range(from, upto)
          @finded_job = result
          true
        else
          false
        end
      end

      def get_range(from, upto)
        REDIS.zzrange @queue_key, from, upto
      end

    end

  end

end
