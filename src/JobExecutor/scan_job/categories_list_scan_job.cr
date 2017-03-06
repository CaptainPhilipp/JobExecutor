require "./helpers/*"

module JobExecutor
  module Scan

    class CategoriesList < Scan::Job
      JOB_NAME = "categories_list"

      def run : Void
        @page = Analizis::Page.new @source_uri, @options.value[JOB_NAME]
        @page.as(Analizis::Page).read
      end



    end
  end
end
