class Subtask < ApplicationRecord
  belongs_to :task

  def completed
    !completed_at.nil?
  end
end
