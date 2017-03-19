module JobExecutor
  module Scan

    class Task
      @start   : Float64
      @src_ids : Array(String)
      @jobs    : Array(String)
      @is_test : Bool

      def initialize(specification : Hash)
        @start    = Time.now.epoch_ms.to_f
        @src_ids  = specification["sources"].to_a.map(&.to_s)
        @jobs     = specification["types"].to_a.map(&.to_s) & SCAN_TYPES_LIST
        @is_test  = specification["is_test"] == "true"
        @options  = TaskOptions.new
        options   = specification["options"]
        @results  = Hash(String, Hash(Int32, Job)).new
        @channel  = Channel(Tuple(String, Int32, Job)).new

        save_options(dummy_options)
      end

      def run
      #   prepare_report
        spawn_all_sources # spawn each source > do each job > send channel
        recieve_all_source_jobs # all sources > all jobs > recieve channels
      # ensure
      #   send_report
      end

      # for now
      def dummy_options
        {
          "categories_list" => {
            "first" => {
              "max_deep" => 1
            }
          },

          "products_list" => {
            "first" => {
              "max_deep" => 1
            }
          },

          "product_scan" => {
            "first" => {
              "max_deep" => 1
            }
          }
        }
      end

      private def save_options(options)
        each_mode(options) do |job, mode, options_hash|
          option_set = OptionSet.new
          option_set.fill_with(options_hash)
          @options[job][mode] = option_set
        end
      end

      private def each_mode(options)
        options.each do |job_name, modes_hash|
          modes_hash.each do |mode_name, options_hash|
            yield job_name, mode_name, options_hash
          end
        end
      end

      # spawn each source { do each job; send channel }
      private def spawn_all_sources : Void
        get_sources.each do |source_id, source|
          spawn { run_all_jobs(source_id, source) }
        end
      end

      private def job_classes
        {Scan::CategoriesList, Scan::ProductsList, Scan::Product}
      end

      private def run_all_jobs(source_id, source) : Void
        job_classes.each_with_index do |job_class, i|
          job_name = SCAN_TYPES_LIST[i]
          next unless @jobs.includes?(job_name)

          job_options = @options[job_name]? ? @options[job_name] : OptionsOfJob.new
          job = job_class.new(source, pointerof(job_options))
          job.run

          @channel.send( {job_name, source_id, job} )
        end
      end

      private def recieve_all_source_jobs
        total_count = @src_ids.size * @jobs.size
        total_count.times do
          job_name, source_id, job = @channel.receive
          @results[job_name] ||= Hash(Int32, Job).new
          @results[job_name][source_id] = job
        end
      end

      private def prepare_report
        @report_init_time = Time.now
        data = {
          content:    "waiting for results".to_json,
          is_test:    @is_test,
          created_at: @report_init_time,
          updated_at: @report_init_time
        }

        ScanReport.insert(data)
      end

      private def send_report
        total_time = Time.now.epoch_ms - @start

        data = {
          content:    results_to_hash.to_json,
          total_time: total_time.to_f,
          updated_at: Time.now
        }

        ScanReport.where("created_at", @report_init_time).update(data)
      end

      private def results_to_hash
        serialized = Hash(String, Hash(Int32, Job::Serialized)).new

        @results.each do |job_name, sources|
          serialized[job_name] ||= Hash(Int32, Job::Serialized).new
          sources.each do |source_id, job|
            serialized[job_name][source_id] = job.prepare_serialize
          end
        end
        serialized
      end

      # private def prepare_serialize(some)
      #   case
      #   when some.responds_to? :prepare_serialize
      #     some.prepare_serialize
      #   when [Hash, NamedTuple].includes? some.class
      #     some.each { |k, v| some[k] = prepare_serialize(v) }
      #   when [Array, Tuple].includes? some.class
      #     some.each_with_idex { |v, k| some[k] = prepare_serialize(v) }
      #   when some.responds_to? :to_json
      #     some
      #   when some.nil?
      #     nil
      #   end
      # end

      private def get_sources : Hash(Int32, String)
        result = Hash(Int32, String).new

        Source.in(:id, @src_ids).all do |rs|
          source_id  = rs.read(Int32)
          uri = rs.read(String)
          result[source_id] = uri
        end

        result
      end
    end # class
  end
end
