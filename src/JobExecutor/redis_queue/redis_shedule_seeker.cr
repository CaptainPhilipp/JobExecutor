# TODO finish shedule scaning
module JobExecutor

  # Run fibers for each queue
  class RedisScheduleSeeker
    include Helper
    getter :redis, :queue

    @finded_jobs : Array(String)?

    def initialize(@redis : Redis) : Void
      @queue_key = get_full_queue_key(Config::SCHEDULE_QUEUE)

      schedule_machine.trigger(:run)
    end

    def schedule_machine : StateMachine
      machine = StateMachine.new(:stop)
      machine.when :run,              { stop: :look_past }
      machine.when :have_jobs,        { look_past: :do_jobs }
      machine.when :jobs_is_done,     { do_jobs: :look_past }

      machine.on :look_past do
        look_for_a_job(upto: Time.now.epoch) && machine.trigger!(:have_jobs)
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

      machine
    end

    def look_for_a_job(*, from = 0, upto : I_32) : Bool
      @finded_jobs = redis.zzrange @queue_key, from, to
      @finded_jobs.any?
    end

  end

end
