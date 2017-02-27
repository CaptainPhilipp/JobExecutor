require "pg"
require "query-builder"

alias DBq = DBquery

# .table_name(table) set base table for class (instead of each-time-input)
# .table(table ?) begin query building
# .all(table ?)   execute query,    output: PG::ResultSet
# .all(table ?)   {} execute query, yield: each in PG::ResultSet
# #all(table ?)   finish and execute builded query,    output: PG::ResultSet
# #one(table ?)   finish and execute builded query,    output: PG::ResultSet
# #all(table ?)   {} finish and execute builded query, yield: each in PG::ResultSet
# #one(table ?)   {} finish and execute builded query, yield: each in PG::ResultSet
class DBquery < Query::Builder
  @@connection = DB.open(DB_CONFIG).as(DB::Database)
  @@table_name = ""

  # for redifinition in nested class
  def self.table_name(name = "none") : String
    @@table_name = name
  end

  # START
  # Start query building with ".table()" instead of ".new.table()"
  # "DBexec.table()..." instead of "DBexec.new.table()..."
  def self.table(table_name = @@table_name) : self
    new.table(table_name)
  end

  # FINISH
  # Finish and execute query
  def self.all(table_name = @@table_name) : PG::ResultSet
    new.table(table_name).all
  end

  # FINISH
  # Finish and execute query
  def self.all(table_name = @@table_name, &block) : Void
    result_set = all(table_name)
    result_set.each do
      yield result_set
    end
  end

  # FINISH
  # Finish and execute query
  def all : PG::ResultSet
    @@connection.query(self.get_all)
  end

  # FINISH YIELD
  # yielding executed ResultSet for .read for each element
  def all(&block) : Void
    result_set = all
    result_set.each do
      yield result_set
    end
  end

  # FINISH
  # finish and execute query
  def one : PG::ResultSet
    @@connection.query(self.get)
  end

  # FINISH YIELD
  # yielding executed ResultSet for element .read
  def one(&block) : Void
    result_set = one
    result_set.each do
      yield result_set
    end
  end

  #
  # redefine for "DBquery.fin_method args"
  #      and "DBquery.methods.fin_method args"
  #

  def insert(datas : Hash | NamedTuple)
    @@connection.exec super
  end

  def update(datas : Hash | NamedTuple)
    @@connection.exec super
  end

  def delete
    @@connection.exec super
  end

  def self.insert(datas : Hash|NamedTuple)
    table.insert datas
  end

  def self.update(datas : Hash|NamedTuple)
    table.update datas
  end

  #
  # redefine for "DBquery.method args"
  #

  def self.select(values)
    table.select values
  end

  def self.in(*values)
    table.in *values
  end

  def self.where(*values)
    table.where *values
  end
end
