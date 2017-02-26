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

  def update_from_form(attributes = nil)
    update(self.class.transmorgrify_completed(attributes))
    self
  end

  def update_with_side_effects(attributes)
    assign_attributes(self.class.transmorgrify_completed(attributes))
    if completed
      self.position = nil
    else
      self.position = self.class.max_position + 1
    end
    save!
    self
  end

  def self.new_with_side_effects(attributes)
    task = new(transmorgrify_completed(attributes))
    if task.completed
      task.position = nil
    else
      task.position = max_position + 1
    end
    task
  end

  def self.new_from_form(attributes = nil)
    new(transmorgrify_completed(attributes))
  end

  def self.display_list(show_completed = false)
    order("position IS NULL, position DESC, created_at DESC")
      .show_completed(@show_completed)
  end

  def self.max_position
    highest_task = where("position IS NOT NULL").order("position DESC").first
    if highest_task.nil?
      0
    else
      highest_task.position
    end
  end

  def self.transmorgrify_completed(attributes)
    if attributes
      completed = attributes.delete(:completed)

      if completed == '1' || completed == true
        attributes[:completed_at] = Time.now
      elsif completed == '0'
        attributes[:completed_at] = nil
      end
    end

    attributes
  end
end
