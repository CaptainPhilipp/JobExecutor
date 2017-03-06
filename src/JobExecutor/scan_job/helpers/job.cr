module JobExecutor
  module Scan

    class Job
      @source_uri : String
      @page       : Analizis::Page?
      @options    : Pointer(Hash(String, Hash(String, Hash(String, Int32))))

      def initialize(@source_uri, @options) end

      def run : Void; end

      def prepare_serialize : Hash(Symbol, String | Nil | Array(Array(Hash(Symbol, String | Array(String))?)?) )
        page = @page ? @page.as(Analizis::Page).prepare_serialize : nil
        { uri:  @source_uri,
          page: page }.to_h
      end

    end
  end
end
