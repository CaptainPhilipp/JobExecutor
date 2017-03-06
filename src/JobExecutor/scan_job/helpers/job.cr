module JobExecutor
  module Scan

    class Job
      alias SERIALIZED = Hash(Symbol, Nil | String | Analizis::Page::SERIALIZED )
      alias OPTIONS = JobController::OPTIONS*

      @source_uri : String
      @page       : Analizis::Page?
      @options    : OPTIONS

      def initialize(@source_uri, @options) end

      def run : Void; end

      def prepare_serialize : SERIALIZED
        page = @page ? @page.as(Analizis::Page).prepare_serialize : nil
        { uri:  @source_uri,
          page: page }.to_h
      end

      def get_job_options
        @options.value[@@job_name] if @options.value[@@job_name]?
      end
    end
  end
end
