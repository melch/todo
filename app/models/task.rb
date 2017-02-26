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

  def self.new_from_form(attributes = nil)
    new(transmorgrify_completed(attributes))
  end

  def update_from_form(attributes = nil)
    update(self.class.transmorgrify_completed(attributes))
    self
  end

  def self.transmorgrify_completed(attributes)
    if attributes
      completed = attributes.delete(:completed)

      if completed == '1'
        attributes[:completed_at] = Time.now
      elsif completed == '0'
        attributes[:completed_at] = nil
      end
    end

    attributes
  end
end
