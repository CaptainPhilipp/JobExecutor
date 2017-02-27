module JobExecutor
  module RedisSeeker

    
    module Helper
      def get_full_queue_key(queue) : String
        "#{APP_NAME}:#{ENV_NAME}:#{queue}:queue"
      end

    end

  end
end
