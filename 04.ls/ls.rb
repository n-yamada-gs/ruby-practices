# frozen_string_literal: true

# files = Dir.children('.').reject { |x| x.start_with?('.') }.sort
files = Dir.glob('*')

def row_length(files)
  files.size.ceildiv(3)
end

def format_files(files, row_number)
  file_matrix = []
  files.each_with_index do |file, index|
    row = index.divmod(row_number)[1]
    col = index.divmod(row_number)[0]
    file_matrix[row] ||= []
    file_matrix[row][col] = file
  end
  file_matrix
end

def output(files, file_matrix)
  max_length = files.max_by { |x| x.to_s.size }.size
  file_matrix.each do |row|
    row.each do |col|
      print "#{col.ljust(max_length)} "
    end
    puts
  end
end

file_matrix = format_files(files, row_length(files))
output(files, file_matrix)
