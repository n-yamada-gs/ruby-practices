# frozen_string_literal: true

COLUMNS = 3

files = Dir.glob('*')
if files.empty?
  puts
  exit
end

def row_length(files)
  files.size.ceildiv(COLUMNS)
end

def format_files(files, row_number)
  file_matrix = []
  files.each_with_index do |file, index|
    col, row = index.divmod(row_number)
    file_matrix[row] ||= []
    file_matrix[row][col] = file
  end
  file_matrix
end

def output(files, file_matrix)
  max_length = files.max_by { |x| x.to_s.size }.size
  file_matrix.each do |row|
    puts row.map { it.ljust(max_length) }.join(' ')
  end
end

file_matrix = format_files(files, row_length(files))
output(files, file_matrix)
