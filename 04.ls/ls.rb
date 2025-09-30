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

if params[:l]
  # ハードリンクの数の桁数
  hard_links = files.map { |file| File.stat(file).nlink }
  max_hard_link_length = hard_links.max.to_s.size
  # ユーザー名の最大文字数
  user_names = files.map do |file|
    user_id = File.stat(file).uid
    Etc.getpwuid(user_id).name
  end
  max_user_name_length = user_names.max_by(&:size).size
  # グループ名の最大文字数
  files.map do |file|
    group_id = File.stat(file).gid
    Etc.getpwuid(group_id).name
  end
  max_group_name_length = user_names.max_by(&:size).size
  # バイトサイズの桁数
  bite_size = files.map { |file| File.size(file) }
  max_bite_size_length = bite_size.max.to_s.size

  # 「合計」の表示
  total = 0
  files.each do |file|
    total += File.stat(file).blocks * 512 / 1024
  end
  puts "合計 #{total}"
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

  files.each do |file|
    file_type = convert_file_type(file)
    mode_number = File.stat(file).mode.to_s(8)[-3..]
    mode_sign = convert_mode_sign(mode_number)

    user_id = File.stat(file).uid
    group_id = File.stat(file).gid

    print file_type
    print mode_sign.join
    print " #{File.stat(file).nlink.to_s.rjust(max_hard_link_length)}"
    print " #{Etc.getpwuid(user_id).name.rjust(max_user_name_length)}"
    print " #{Etc.getpwuid(group_id).name.rjust(max_group_name_length)}"
    print " #{File.size(file).to_s.rjust(max_bite_size_length)}"
    print " #{File.stat(file).mtime.strftime('%m月 %d %R')}"
    puts " #{file}"
  end
else # -lオプションなしの時の処理
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
end
