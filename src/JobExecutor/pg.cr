require "db"
require "pg"

require "./pg/*"


db = DB.open DB_CONFIG
  # respond = db.exec "insert into parser_sources source_url='test';"

db.query "select * from parser_sources;" do |rs|
  rs.each do
    puts rs.read(Int32)
  end
end
