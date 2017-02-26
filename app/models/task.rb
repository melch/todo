class Task < ApplicationRecord
  validates :name, uniqueness: true

  def self.new_from_form(attributes = nil)
    self.new(transmorgrify_completed(attributes))
  end

  def update_from_form(attributes = nil)
    self.update(self.class.transmorgrify_completed(attributes))
    self
  end

  def self.transmorgrify_completed(attributes)
    if attributes
      completed = attributes.delete(:completed)

      if completed == '1'
        attributes.merge!(completed_at: Time.now)
      elsif completed == '0'
        attributes.merge!(completed_at: nil)
      end
    end

    attributes
  end
end
