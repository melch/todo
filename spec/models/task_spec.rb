require "rails_helper"

RSpec.describe Task, :type => :model do
  let(:task) { Task.new }

  it 'should prevent duplicate names' do
    Task.create!(name: 'name')
    task = Task.new(name: 'name')
    expect(task.valid?).to be false
    expect(task.errors[:name]).to include('has already been taken')
  end

  it "should have columns" do
    expect(task.name).to eq(nil)
  end

  describe '.new_from_form' do
    it 'should set completed_at if completed true is passed' do
      now = Time.now
      Timecop.freeze(now) do
        expect(Task.new_from_form(completed: '1').completed_at).to eq(now)
      end
    end

    it 'should leave completed_at nil if "0" is passed' do
      expect(Task.new_from_form(completed: '0').completed_at).to be nil
    end

    it 'should handle nil attributes' do
      now = Time.now
      Timecop.freeze(now) do
        expect(Task.new_from_form.completed_at).to be_nil
      end
    end
  end
end
