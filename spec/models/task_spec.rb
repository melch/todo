require "rails_helper"

RSpec.describe Task, :type => :model do
  let(:task) { Task.new }
  it "should have columns" do
    expect(task.name).to eq(nil)
  end
end
