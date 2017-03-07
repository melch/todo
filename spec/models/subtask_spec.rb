require "rails_helper"

RSpec.describe Subtask, type: :model do
  let(:subtask) { described_class.new }

  it 'has a name' do
    subtask.name = 'subtask'
  end
end
