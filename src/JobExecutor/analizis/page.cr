require "http/client"
require "xml"
require "./helpers/*"


module Analizis
  class Page
    include Helper

    alias OPTIONS    = Hash(String, Hash(String, Int32)) #job# {#mode: {#option: #value}}
    alias SERIALIZED = Array(Sequence::SERIALIZED)

    @doc : XML::Node?
    @options : OPTIONS

    def initialize(url, @options)
      @body = get_body(url)
      @sequences = [] of Sequence
    end



    def read
      return if @body.empty?
      @doc  = XML.parse_html(@body)
      @body = ""
      traverse_tree
    end



    private def traverse_tree(node = @doc)
      return if node.nil?
      childrens = all_childrens(node)
      sequence = Sequence.new(childrens, pointerof(@options))
        @sequences << sequence # прост))
      if sequence.relevant?
        @sequences << sequence
        #
        #
      else
        childrens.each_with_index { |child| traverse_tree(child) }
      end
    end



    def prepare_serialize : SERIALIZED
      @sequences.map(&.prepare_serialize).reject(&.nil?)
    end



    private def get_body(url, retry = false)
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



    private def cache
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
