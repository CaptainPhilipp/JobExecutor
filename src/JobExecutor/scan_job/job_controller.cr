module JobExecutor
  module Scan

    class JobController
      @start   : Float64
      @src_ids : Array(String)
      @jobs    : Array(String)
      @is_test : Bool

      def initialize(specification : String)
        options   = JSON.parse specification
        @start    = Time.now.epoch.to_f
        @src_ids  = options["sources"].to_a.map(&.to_s)
        @jobs     = options["types"].to_a.map(&.to_s) & SCAN_TYPES_LIST
        @is_test  = options["is_test"] == "true"
        @results  = Hash(String, Hash(Int32, Job)).new
        @channel  = Channel(Tuple(String, Int32, Job)).new

        do_job_for_every_source
      end



      def do_job_for_every_source
        spawn_all_jobs # spawn each source { do each job; send channel }

        total_count = @src_ids.size * @jobs.size
        total_count.times do
          job_name, source_id, job = @channel.receive
          @results[job_name] ||= Hash(Int32, Job).new
          @results[job_name][source_id] = job
        end

        send_report
      end



      # spawn each source { do each job; send channel }
      def spawn_all_jobs : Void
        get_sources.each do |source_id, source|
          spawn do
            each_job do |job, job_name|
              @channel.send( {job_name, source_id, job.new(source)} )
            end
          end
        end
      end



      def each_job : Void
        job_constants.each_with_index do |job_constant, i|
          job_name = SCAN_TYPES_LIST[i]
          yield job_constant, job_name if @jobs.includes? job_name
        end
      end



      private def job_constants
        {Scan::CategoriesList, Scan::ProductsList, Scan::Product}
      end



      def send_report
        total_time = @start - Time.now.epoch.to_f

        data = {
          content:    @results.to_json,
          is_test:    @is_test,
          total_time: total_time,
          created_at: Time.now,
          updated_at: Time.now
        }

        ScanReport.insert(data)
      end



      def get_sources : Hash(Int32, String)
        result = Hash(Int32, String).new

        Source.in(:id, @src_ids).all do |rs|
          source_id  = rs.read(Int32)
          uri = rs.read(String)
          result[source_id] = uri
        end

        result
      end



    end

  end
end
