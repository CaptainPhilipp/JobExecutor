require "http/client"

module JobExecutor
  module Scan

    class Job
      @source_uri   : String
      @page         : Analizis::Page?

      # options just sending to next object in Pointer
      def initialize(@source_uri, @job_options : OptionsOfJob*) end

      def run : Void
        body  = get_body_from URI.parse(@source_uri)
        doc   = XML.parse_html(body)
        @page = Analizis::Page.new(doc, @job_options)
      end

      private def get_body_from(url, *, retry = false)
        puts "retry (#{url})" if retry
        HTTP::Client.get(url).body
      rescue ex
        print "\nERROR in '#{url}': '#{ex}'"
        print retry ? " NOT RESOLVED!" : "\n"
        if retry
          puts "Can't open #{url}"
          return ""
        else
          url.scheme = (url.scheme == "http" ? "https" : "http" )
          get_body_from url, retry: true
        end
      end

      alias Serialized = Hash(Symbol, Nil | String | Analizis::Page::Serialized)

      def prepare_serialize : Serialized
        page = @page ? @page.as(Analizis::Page).prepare_serialize : nil
        Hash{ "uri" => @source_uri, "page" => page }
      end

      # private def cache
      #   filename = @url.to_s.split("/")[3..-1].join(".").gsub(/[[[:punct:]][[:blank:]]]/, ".")
      #   root = "/Crystal/job_executor"
      #   dir = root + ".tmp" + uri.host.as(String)
      #   path = "#{dir}/#{filename}"
      #   Dir.mkdir_p dir
      #   IO.copy(HTTP::Client.get(@url).body, path) unless File.exists? path
      #   path
      # end
    end
  end
end
