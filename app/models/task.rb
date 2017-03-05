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
      if update_from_attributes(attrs)
        if position && (id && self.class.where(position: position).where.not(id: id).any?)
          self.class.where("position >= ?", position).where.not(id: id).each do |other_task|
            other_task.update(position: other_task.position + 1)
          end
        end
      end
    end
    self
  end

  def update_from_attributes(attrs)
    self.completed_at = new_completed_at(attrs[:completed])
    self.position = new_position(attrs)

    save
  end

  def new_position(attrs)
    if attrs[:completed]
      nil
    else
      position || attrs[:position] || self.class.max_position + 1
    end
  end
  private :new_position

  def new_completed_at(completed_attr)
    if completed_attr == '1' || completed_attr == true
      Time.now
    elsif completed_attr == '0'
      nil
    end
  end

  def self.new_with_side_effects(attrs)
    task = new(transmorgrify_completed(attrs))
    if position = attrs[:position]
      where("position >= ?", position).all.each do |other_task|
        other_task.update(position: other_task.position + 1)
      end
      task.position = position
    else
      task.position = task.send(:next_position)
    end
    task
  end

  def next_position
    if completed
      nil
    else
      self.class.max_position + 1
    end
  end
  private :next_position

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

  def self.transmorgrify_completed(attrs)
    if attrs
      completed = attrs.delete(:completed)

      if completed == '1' || completed == true
        attrs[:completed_at] = Time.now
      elsif completed == '0'
        attrs[:completed_at] = nil
      end

      if completed
        attrs[:position] = nil
      else
        attrs[:position] ||= max_position + 1
      end
    end

    attrs
  end
end
