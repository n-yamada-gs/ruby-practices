#!/usr/bin/env ruby
# frozen_string_literal: true

score = ARGV[0]
scores = score.split(',')
shots = []
scores.each do |s|
  if s == 'X'
    shots << 10
    shots << 0
  else
    shots << s.to_i
  end
end

frames = shots.each_slice(2).to_a

point = 0
frames.each_with_index do |frame, index|
  point += frame.sum
  if index <= 8
    if frames[index][0] == 10
      point += (frames[index + 1][0] + frames[index + 1][1])
      point += frames[index + 2][0] if frames[index + 1][0] == 10
    elsif frames[index][0] + frames[index][1] == 10
      point += frames[index + 1][0]
    end
  end
end

puts point
