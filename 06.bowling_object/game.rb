# frozen_string_literal: true

require_relative 'frame'

# ゲーム全体のスコア
class Game
  attr_reader :frames

  def initialize(marks)
    @frames = make_frames(marks)
  end

  def total_score
    frames.each_with_index.sum do |frame, frame_index|
      frame_score(frame, frame_index)
    end
  end

  private

  def make_frames(marks)
    shots = marks.split(',')
    frames = Array.new(9) do
      first_mark = shots.shift
      first_mark == 'X' ? Frame.new(first_mark) : Frame.new(first_mark, shots.shift)
    end
    frames << Frame.new(*shots)
  end

  def regular_frame?(frame_index)
    frame_index < 9
  end

  def frame_score(frame, frame_index)
    return frame.last_frame_score unless regular_frame?(frame_index)

    if frame.strike?
      strike_score(frame_index)
    elsif frame.spare?
      spare_score(frame_index)
    else
      frame.regular_frame_score
    end
  end

  def spare_score(frame_index)
    frames[frame_index].regular_frame_score + frames[frame_index + 1].first_shot.score
  end

  def strike_score(frame_index)
    frames[frame_index].first_shot.score + frames[frame_index + 1].first_shot.score + strike_bonus_score(frame_index)
  end

  def strike_bonus_score(frame_index)
    if frame_index == 8
      frames[frame_index + 1].second_shot.score
    else
      frames[frame_index + 1].strike? ? frames[frame_index + 2].first_shot.score : frames[frame_index + 1].second_shot.score
    end
  end
end
