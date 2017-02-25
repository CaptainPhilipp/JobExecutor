module Helper
  def queue_name_to_full_key(queue) : String
    "#{Config::APP_NAME}:#{Config::ENV}:#{queue}:queue"
  end
end
