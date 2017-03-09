require "http/client"
require "xml"
require "./helpers/*"


module Analizis
  class Page
    include Helper

    alias Serialized  = Array(Sequence::Serialized)

    def initialize(url, @options : Signature::ModeOptions)
      @body = get_body_from URI.parse(url)
      @sequences = [] of Sequence
    end



    def read
      return if @body.empty?
      @doc  = XML.parse_html(@body).as XML::Node?
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



    def prepare_serialize : Serialized
      @sequences.map(&.prepare_serialize).reject(&.nil?)
    end



    private def get_body_from(url, retry = false)
      puts "retry (#{url})" if retry
      HTTP::Client.get(url).body
    rescue ex
      puts "\nERROR in '#{url}': '#{ex}'" + (retry ? " NOT RESOLVED!" : "")
      if retry
        puts "Can't open #{url}"
        return ""
      else
        url.scheme = (url.scheme == "http" ? "https" : "http" )
        get_body_from url, true
      end
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
  end # class
end
