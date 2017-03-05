class Task < ApplicationRecord
  validates :name, uniqueness: true

  scope :show_completed, ->(show_completed) {
    if show_completed
      all
    else
      where(completed_at: nil)
    end
  }

  def completed
    !completed_at.nil?
  end

  def update_with_side_effects(attrs)
    transaction do
      self.completed_at = new_completed_at(attrs[:completed])
      self.position = new_position(attrs)

      save!

      push_other_positions!
    end
    self
  end

  def self.display_list(show_completed = false)
    order("position IS NULL, position DESC, created_at DESC")
      .show_completed(show_completed)
  end

  def self.max_position
    highest_task = where("position IS NOT NULL").order("position DESC").first
    if highest_task.nil?
      0
    else
      highest_task.position
    end
  end

  private

  def next_position
    if completed
      nil
    else
      self.class.max_position + 1
    end
  end

  def new_completed_at(completed_attr)
    if completed_attr == '1' || completed_attr == true
      Time.now
    elsif completed_attr == '0'
      nil
    end
  end

  def new_position(attrs)
    if attrs[:completed]
      nil
    else
      position || attrs[:position] || self.class.max_position + 1
    end
  end

  def push_other_positions!
    return unless position_overlap?

    tasks_to_push.each do |other_task|
      other_task.update!(position: other_task.position + 1)
    end
  end

  def position_overlap?
    position && self.class.where(position: position).where.not(id: id).any?
  end

  def tasks_to_push
    self.class.where("position >= ?", position).where.not(id: id)
  end
end
