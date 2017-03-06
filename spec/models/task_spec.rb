require "rails_helper"

RSpec.describe Task, type: :model do
  let(:task) { described_class.new }

  it 'should prevent duplicate names' do
    described_class.create!(name: 'name')
    task = described_class.new(name: 'name')
    expect(task.valid?).to be false
    expect(task.errors[:name]).to include('has already been taken')
  end

  it "should have columns" do
    expect(task.name).to eq(nil)
  end

  it 'should remove position when completed' do
    task = described_class.create!(name: "delete me", position: 1)
    task.destroy
    expect(described_class.where(position: 1)).to be_empty
  end

  describe "#max_position" do
    it 'should return 0 when no tasks exist' do
      expect(described_class.max_position).to eq 0
    end

    it 'should return 1 if no tasks have positions' do
      described_class.create!(name: "first psot!1", position: 1)
      expect(described_class.max_position).to eq 1
    end

    it 'should return maximum position if a task with a position exits' do
      described_class.create!(name: "first psot!1", position: 1)
      described_class.create!(name: "interesting dialogue", position: 2)
      described_class.create!(
        name: "For your record only",
        position: nil,
        completed_at: Time.now
      )
      expect(described_class.max_position).to eq 2
    end
  end

  describe '#update_with_side_effects' do
    it 'should set attributes passed' do
      name = "Write a Todo App"
      description = "then iterate on it"
      attrs = {
        description: description,
        name: name,
        completed: false,
      }

      task = described_class.new.update_with_side_effects(attrs)
      expect(task.name).to eq name
      expect(task.description).to eq description
      expect(task.completed_at).to eq nil
    end

    it 'should clear position if completed' do
      task = described_class.create!(name: "update me", position: 1)
      task.update_with_side_effects(completed: '1')
      expect(task.reload.position).to be nil
    end

    it 'should set position if passed and not completed' do
      task = described_class.create!(name: "update me")
      task.update_with_side_effects(name: 'still not done', position: 42, completed: "0")
      expect(task.reload.position).to eq(42)
    end

    it 'should shift position of other tasks if position is already taken' do
      old_first = described_class.create!(name: "first psot!1", position: 1)
      old_second = described_class.create!(name: "interesting dialogue", position: 2)

      task = described_class.create!(name: "update me")
      task.update_with_side_effects(position: 1)
      expect(task.position).to eq 1
      expect(old_first.reload.position).to eq 2
      expect(old_second.reload.position).to eq 3
    end

    it 'should not shift position of other tasks if task is complete' do
      old_first = described_class.create!(name: "first psot!1", position: 1)
      old_second = described_class.create!(name: "interesting dialogue", position: 2)

      task = described_class.create!(name: "update me", position: 1)
      task.update_with_side_effects(position: 1, completed: true)
      expect(old_first.position).to eq 1
      expect(old_second.position).to eq 2
    end
  end
end
