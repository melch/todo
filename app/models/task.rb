class Task < ApplicationRecord
  validates :name, uniqueness: true

  def self.new_from_form(attributes = nil)
    if attributes && attributes.delete(:completed) == '1'
      attributes.merge!(completed_at: Time.now)
    end

    self.new(attributes)
  end
end
