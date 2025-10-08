# frozen_string_literal: true

COLUMNS = 3

require 'optparse'
require 'etc'
opt = OptionParser.new

params = {}
opt.on('-l') { params[:l] = true }
opt.parse!(ARGV)

files = Dir.glob('*')
exit if files.empty?

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

# -lオプションに必要なデータたち
def get_long_format_datas(files)
  files.map do |file|
    stat = File.stat(file)
    {
      name: file,
      file_type: File.ftype(file),
      nlink: stat.nlink,
      mode_number: stat.mode.to_s(8)[-3..],
      user_id: stat.uid,
      group_id: stat.gid,
      byte_size: stat.size,
      time: stat.mtime,
      total: stat.blocks
    }
  end
end
raw_datas = get_long_format_datas(files)
# ユーザー名とグループ名を取得し、ハッシュを追加する
def add_user_and_group_names(raw_datas)
  raw_datas.map do |data|
    user_name = Etc.getpwuid(data[:user_id]).name
    group_name = Etc.getgrgid(data[:group_id]).name
    data.merge(user_name: user_name, group_name: group_name)
  end
end
long_format_datas = add_user_and_group_names(raw_datas)

# ハードリンクの数の桁数
def get_max_hard_link_digit_length(long_format_datas)
  hard_links = long_format_datas.map { |data| data[:nlink] }
  hard_links.max.to_s.size
end

# ユーザー名の最大文字数
def get_max_user_name_length(long_format_datas)
  long_format_datas.map { |data| data[:user_name].size }.max
end

# グループ名の最大文字数
def get_max_group_name_length(long_format_datas)
  long_format_datas.map { |data| data[:group_name].size }.max
end

# バイトサイズの桁数
def get_max_byte_size_digit_length(long_format_datas)
  byte_size = long_format_datas.map { |data| data[:byte_size] }
  byte_size.max.to_s.size
end

# 「合計」の表示
def get_total(long_format_datas)
  long_format_datas.sum { |data| data[:total] * 512 / 1024 }
end

# ファイルタイプ（モード）を1文字に変換する
def convert_file_type(data)
  case data[:file_type]
  when 'file' then '-'
  when 'directory' then 'd'
  when 'link' then 'l'
  else '?'
  end
end

# パーミションの数字を記号表記に変換する
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

def print_in_long_format(long_format_datas, max_hard_link_digit_length, max_user_name_length, max_group_name_length, max_byte_size_digit_length)
  long_format_datas.each do |data|
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

if params[:l]
  total_block_size = get_total(long_format_datas)
  puts "合計 #{total_block_size}"
  max_hard_link_digit_length = get_max_hard_link_digit_length(long_format_datas)
  max_user_name_length = get_max_user_name_length(long_format_datas)
  max_group_name_length = get_max_group_name_length(long_format_datas)
  max_byte_size_digit_length = get_max_byte_size_digit_length(long_format_datas)
  print_in_long_format(long_format_datas, max_hard_link_digit_length, max_user_name_length, max_group_name_length, max_byte_size_digit_length)
else
  print_in_short_format(files)
end
