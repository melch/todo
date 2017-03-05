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

  describe '.transmorgrify_completed' do
    it 'should handle nil' do
      attrs = nil
      transmorgrified = described_class.transmorgrify_completed(attrs)
      expect(transmorgrified).to be nil
    end

    it 'should return non-completed attributes as is' do
      attrs = { foo: :bar }
      transmorgrified = described_class.transmorgrify_completed(attrs)
      expect(transmorgrified).to be attrs
    end

    it 'should turn completed "1" to completed_at Time.now' do
      attrs = { completed: '1', pass: :through }
      now = Time.now
      Timecop.freeze(now) do
        transmorgrified = described_class.transmorgrify_completed(attrs)
        expect(transmorgrified).to eq(completed_at: now, pass: :through)
      end
    end

    it 'should turn completed true to completed_at Time.now' do
      attrs = { completed: true, pass: :through }
      now = Time.now
      Timecop.freeze(now) do
        transmorgrified = described_class.transmorgrify_completed(attrs)
        expect(transmorgrified).to eq(completed_at: now, pass: :through)
      end
    end

    it 'should turn completed "0" to completed_at nil' do
      attrs = { completed: '0' }
      transmorgrified = described_class.transmorgrify_completed(attrs)
      expect(transmorgrified).to eq(completed_at: nil)
    end
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

    it 'should return 0 if no tasks have positions' do
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

  describe '#new_with_side_effects' do
    let(:base_attrs) { { name: "make me" } }
    it 'should assign position if not completed' do
      task = described_class.new_with_side_effects(base_attrs)
      expect(task.position).to eq(described_class.max_position + 1)
    end

    it 'should clear position if completed' do
      completed_attrs = base_attrs.merge(completed: "1")
      task = described_class.new_with_side_effects(completed_attrs)
      expect(task.position).to be nil
    end
  end

  describe '#update_with_side_effects' do
    it 'should assign position if not completed' do
      task = Task.create!(name: "update me", position: 3)
      expect(described_class.max_position).to eq(3)
      updated_task = task.update_with_side_effects(name: 'still not done')
      expect(updated_task.position).to eq(4)
    end

    it 'should clear position if completed' do
      task = Task.create!(name: "update me", position: 1)
      # TODO: accept true for completed also
      updated_task = task.update_with_side_effects(completed: '1')
      expect(updated_task.position).to be nil
    end
  end
end
