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

def print_in_short_format(files, row_number, file_matrix)
  file_matrix = format_files(files, row_length(files))
  output(files, file_matrix)
end

# ハードリンクの数の桁数
def get_max_hard_link_digit_length(files)
  hard_links = files.map { |file| File.stat(file).nlink }
  max_hard_link_digit_length = hard_links.max.to_s.size
end
# ユーザー名の最大文字数
def get_user_name_length(files)
  user_names = files.map do |file|
    user_id = File.stat(file).uid
    Etc.getpwuid(user_id).name
  end
  max_user_name_length = user_names.max_by(&:size).size
end
# グループ名の最大文字数
def get_max_group_name_length(files)
  group_names = files.map do |file|
    group_id = File.stat(file).gid
    Etc.getpwuid(group_id).name
  end
  max_group_name_length = group_names.max_by(&:size).size
end
# バイトサイズの桁数
def get_max_bite_size_digit_length(files)
  bite_size = files.map { |file| File.size(file) }
  max_bite_size_digit_length = bite_size.max.to_s.size
end
# 「合計」の表示
def get_total
  total_block_size =  files.sum { |file| File.stat(file).blocks * 512 / 1024 }
  puts "合計 #{total_block_size}"
end
# ファイルタイプ（モード）を1文字に変換する
def convert_file_type(file)
  case File.ftype(file)
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

def print_in_long_format(files, max_hard_link_digit_length, max_user_name_length, max_group_name_length, max_bite_size_digit_length)
  files.each do |file|
    file_type = convert_file_type(file)
    mode_number = File.stat(file).mode.to_s(8)[-3..]
    mode_sign = convert_mode_sign(mode_number)

    user_id = File.stat(file).uid
    group_id = File.stat(file).gid

    print file_type
    print mode_sign.join
    print " #{File.stat(file).nlink.to_s.rjust(max_hard_link_digit_length)}"
    print " #{Etc.getpwuid(user_id).name.ljust(max_user_name_length)}"
    print " #{Etc.getpwuid(group_id).name.ljust(max_group_name_length)}"
    print " #{File.size(file).to_s.rjust(max_bite_size_digit_length)}"
    print " #{File.stat(file).mtime.strftime('%m月 %d %R')}"
    puts " #{file}"
  end
end

if params[:l]
  max_hard_link_digit_length = get_max_hard_link_digit_length(files)
  max_user_name_length = get_user_name_length(files)
  max_group_name_length = get_max_group_name_length(files)
  max_bite_size_digit_length = get_max_bite_size_digit_length(files)
  print_in_long_format(files, max_hard_link_digit_length, max_user_name_length, max_group_name_length, max_bite_size_digit_length)
else
  row_number = row_length(files)
  file_matrix = format_files(files, row_number)
  print_in_short_format(files, row_number, file_matrix)
end
