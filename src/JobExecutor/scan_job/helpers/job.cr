module JobExecutor
  module Scan

    class Job
      alias Serialized = Hash(Symbol, Nil | String | Analizis::Page::Serialized )
      # alias OPTIONS = JobController::OPTIONS*
      alias OPTIONS = Hash(String, Analizis::Signature::ModeOptions)*

      @source_uri : String
      @page       : Analizis::Page?
      @options    : OPTIONS

      def initialize(@source_uri, @options) end

      def run : Void; end

      def prepare_serialize : Serialized
        page = @page ? @page.as(Analizis::Page).prepare_serialize : nil
        Hash{ uri:  @source_uri,
              page: page }
      end

      def get_job_options
        @options.value[@@job_name]
      end
    end
  end
end
