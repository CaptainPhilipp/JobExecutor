require "http/client"
require "xml"
require "./helpers/*"


module Analizis
  class Page
    include Helper
    @doc : XML::Node?

    def initialize(url)
      body = get_body(url)
      unless body.empty?
        @doc = XML.parse_html(body)
        traverse_tree
      end
    end



    def traverse_tree(node = @doc)
      return if node.nil?
      set = Sequence.new(node)
      if set.relevant?
        #
        # TODO
        #
      else
        each_children(node) { |child| traverse_tree(child) }
      end
    end



    def get_body(url, retry = false)
      puts "retry (#{url})" if retry
      url = url.is_a?(URI) ? url : URI.parse(url)
      HTTP::Client.get(url).body
    rescue ex
      puts "\nERROR in '#{url}': '#{ex}'" + (retry ? " NOT RESOLVED!" : "")
      return "" if retry
      url = url.is_a?(URI) ? url : URI.parse(url)
      url.scheme = (url.scheme == "http" ? "https" : "http" )
      get_body(url.to_s, true)
    end



    def cache
      filename = @url.to_s.split("/")[3..-1].join(".").gsub(/[[[:punct:]][[:blank:]]]/, ".")
      root = "/Crystal/job_executor"
      dir = root + ".tmp" + uri.host.as(String)
      Dir.mkdir_p dir
      path = "#{dir}/#{filename}"
      IO.copy HTTP::Client.get(@url).body, path unless File.exists? path
      path
    end
  end # class
end
