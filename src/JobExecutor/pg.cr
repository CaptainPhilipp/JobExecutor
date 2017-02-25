require "./pg/*"

Source.all do |rs|
  puts "#{rs.read(Int32)} > #{rs.read(String)}"
end
