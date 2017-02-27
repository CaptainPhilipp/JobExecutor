module JobExecutor
  module Scan

    class Job
      @source_uri : String?

      def initialize(@source_uri = nil) end

      def to_json(json : JSON::Builder)
        json.object do
          json.field "source_uri", @source_uri
        end
      end

      def clone
        Job.new(@source_uri)
      end

    end
  end
end
