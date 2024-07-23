#!/usr/bin/env ruby
# frozen_string_literal: true

# ボウリングのスコアを取得し、配列にする
score = ARGV[0]
scores = score.split(',')

# ストライクを10点に変換する。ダミーの2投目を追加する。
shots = []
scores.each do |s|
  if s == 'X'
    shots << 10
    shots << 0
  else
    shots << s.to_i
  end
end

# 1フレームごとに束ねる
frames = shots.each_slice(2).to_a

# ストライクかどうかの判定
def strike?(frame)
  frame[0] == 10
end

# スペアかどうかの判定
def spare?(frame)
  frame[0] + frame[1] == 10
end

# 各フレームのスコアの計算
def frame_score(frame)
  frame.sum
end

# スペアの時のスコアの計算
def spare_score(frames, frame_index)
  [frames[frame_index][0], frames[frame_index][1], frames[frame_index + 1][0]].sum
end

# ストライクの時のスコアの計算
def strike_score(frames, frame_index)
  if frames[frame_index + 1][0] == 10
    [frames[frame_index][0], frames[frame_index + 1][0], frames[frame_index + 2][0]].sum
  else
    [frames[frame_index][0], frames[frame_index + 1][0], frames[frame_index + 1][1]].sum
  end
end

# 合計スコアを計算する
frame_index = 0
total_score = 0
frames.each do |frame|
  total_score += \
    # 1～9フレームのスコア計算
    if frame_index < 9
      if strike?(frame)
        strike_score(frames, frame_index)
      elsif spare?(frame)
        spare_score(frames, frame_index)
      else
        frame_score(frame)
      end
    # 10フレームのスコア計算
    else
      frame_score(frame)
    end
  frame_index += 1
end
puts total_score
