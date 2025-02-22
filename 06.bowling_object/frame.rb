# frozen_string_literal: true

require_relative 'shot'

# 1フレームのスコア
class Frame
  attr_reader :first_shot, :second_shot, :third_shot

  def initialize(first_mark, second_mark = 0, third_mark = 0)
    @first_shot = create_shot(first_mark)
    @second_shot = create_shot(second_mark)
    @third_shot = create_shot(third_mark)
  end

  def regular_frame_score
    [@first_shot, @second_shot].compact.sum(&:score)
  end

  def last_frame_score
    [@first_shot, @second_shot, @third_shot].compact.sum(&:score)
  end

  def strike?
    @first_shot.score == 10
  end

  def spare?
    !strike? && regular_frame_score == 10
  end

  private

  def create_shot(mark)
    mark ? Shot.new(mark) : nil
  end
end
