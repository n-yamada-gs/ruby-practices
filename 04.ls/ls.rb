# frozen_string_literal: true

COLUMNS = 3

require 'optparse'
require 'etc'
opt = OptionParser.new

params = {}
opt.on('-a') { params[:a] = true }
opt.on('-r') { params[:r] = true }
opt.on('-l') { params[:l] = true }
opt.parse!(ARGV)

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

def print_in_short_format(files)
  file_matrix = format_files(files, row_length(files))
  output(files, file_matrix)
end

def long_format_data(files)
  files.map do |file|
    stat = File.stat(file)
    {
      name: file,
      file_type: File.ftype(file),
      nlink: stat.nlink,
      mode_number: stat.mode.to_s(8)[-3..],
      user_name: Etc.getpwuid(stat.uid).name,
      group_name: Etc.getgrgid(stat.gid).name,
      byte_size: stat.size,
      time: stat.mtime,
      total: stat.blocks
    }
  end
end

def max_hard_link_digit_length(long_format_data)
  long_format_data.map { |data| data[:nlink] }.max.to_s.size
end

def max_user_name_length(long_format_data)
  long_format_data.map { |data| data[:user_name].size }.max
end

def max_group_name_length(long_format_data)
  long_format_data.map { |data| data[:group_name].size }.max
end

def max_byte_size_digit_length(long_format_data)
  byte_size = long_format_data.map { |data| data[:byte_size] }
  byte_size.max.to_s.size
end

def total(long_format_data)
  long_format_data.sum { |data| data[:total] * 512 / 1024 }
end

def convert_file_type(data)
  case data[:file_type]
  when 'file' then '-'
  when 'directory' then 'd'
  when 'link' then 'l'
  when 'characterSpecial' then 'c'
  when 'blockSpecial' then 'b'
  when 'fifo' then 'p'
  when 'socket' then 's'
  else '?'
  end
end

def convert_mode_sign(mode_number)
  mode_number.each_char.map do |char|
    case char
    when '0' then '---'
    when '1' then '--x'
    when '2' then '-w-'
    when '3' then '-wx'
    when '4' then 'r--'
    when '5' then 'r-x'
    when '6' then 'rw-'
    when '7' then 'rwx'
    else '?'
    end
  end
end

def print_in_long_format(long_format_data, max_hard_link_digit_length, max_user_name_length, max_group_name_length, max_byte_size_digit_length)
  long_format_data.each do |data|
    file_type = convert_file_type(data)
    mode_number = data[:mode_number]
    mode_sign = convert_mode_sign(mode_number)
    print file_type
    print mode_sign.join
    print " #{data[:nlink].to_s.rjust(max_hard_link_digit_length)}"
    print " #{data[:user_name].ljust(max_user_name_length)}"
    print " #{data[:group_name].ljust(max_group_name_length)}"
    print " #{data[:byte_size].to_s.rjust(max_byte_size_digit_length)}"
    print " #{data[:time].strftime('%m月 %d %R')}"
    puts " #{data[:name]}"
  end
end

flags = params[:a] ? File::FNM_DOTMATCH : 0
files = Dir.glob('*', flags)
files.reverse! if params[:r]

if params[:l]
  long_format_data = long_format_data(files)
  total_block_size = total(long_format_data)
  puts "合計 #{total_block_size}"
  max_hard_link_digit_length = max_hard_link_digit_length(long_format_data)
  max_user_name_length = max_user_name_length(long_format_data)
  max_group_name_length = max_group_name_length(long_format_data)
  max_byte_size_digit_length = max_byte_size_digit_length(long_format_data)
  print_in_long_format(long_format_data, max_hard_link_digit_length, max_user_name_length, max_group_name_length, max_byte_size_digit_length)
else
  exit if files.empty?
  print_in_short_format(files)
end
