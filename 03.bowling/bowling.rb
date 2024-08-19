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

# ボウリングでは、1～9ゲームまで、1フレームで2ショット投げられるので、フレームでまとめる。
frames = shots.each_slice(2).to_a

def strike?(frame)
  frame[0] == 10
end

def spare?(frame)
  !strike?(frame) && frame[0] + frame[1] == 10
end

def spare_score(frames, frame_index)
  [frames[frame_index][0], frames[frame_index][1], frames[frame_index + 1][0]].sum
end

def strike_score(frames, frame_index)
  if frames[frame_index + 1][0] == 10
    [frames[frame_index][0], frames[frame_index + 1][0], frames[frame_index + 2][0]].sum
  else
    [frames[frame_index][0], frames[frame_index + 1][0], frames[frame_index + 1][1]].sum
  end
end

total_score = 0
frames.each_with_index do |frame, frame_index|
  total_score +=
    if frame_index < 9
      if strike?(frame)
        strike_score(frames, frame_index)
      elsif spare?(frame)
        spare_score(frames, frame_index)
      else
        frame.sum
      end
    else
      frame.sum
    end
end
puts total_score
