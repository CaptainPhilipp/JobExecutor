module JobExecutor
  APP_NAME             = "job_executor"
  ENV_NAME             = "development"
  LAZY_INTERVAL        = 5
  AWAKE_INTERVAL       = 0.2
  AWAKE_TIME_LIMIT     = 60 * 1
  SCHEDULE_QUEUE       = "schedule"
  STANDART_QUEUES      = ["default_scan"]
  SCHEDULE_INTERVAL    = 60
  SCAN_TYPES_LIST      = %w(categories_list products_list scan_product)
  PRINT_QUEUER         = true

  alias OptionsOfJob = Hash(String, OptionSet) # mode_name => set
  alias TaskOptions  = Hash(String, OptionsOfJob) # job_name => mode
end
