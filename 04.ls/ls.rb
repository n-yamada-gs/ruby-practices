# frozen_string_literal: true

files = Dir.children('.').sort

def how_many_rows(files)
  (files.size / 3.0).ceil
end

def put_files(files, row_number)
  files_any_rows = []
  files.each_with_index do |file, index|
    row = index % row_number
    col = index / row_number
    files_any_rows[row] ||= []
    files_any_rows[row][col] = file
  end
  files_any_rows
end

def output(files_any_rows)
  files_any_rows.each do |row|
    row.each do |col|
      print "#{col.ljust(16)} "
    end
    puts ''
  end
end

files_any_rows = put_files(files, how_many_rows(files))
output(files_any_rows)
