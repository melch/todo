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

  describe '.new_from_form' do
    it 'should set completed_at from checkbox' do
      now = Time.now
      Timecop.freeze(now) do
        new_task = described_class.new_from_form(completed: '1')
        expect(new_task.completed_at).to eq(now)
      end
    end

    it 'should handle nil attributes' do
      now = Time.now
      Timecop.freeze(now) do
        new_task = described_class.new_from_form
        expect(new_task.completed_at).to be_nil
      end
    end
  end

  describe '.update_from_form' do
    it 'should set from checkbox values' do
      updated_task = task.update_from_form(completed: '0')
      expect(updated_task.completed_at).to be nil
    end

    it 'should return the same type' do
      updated_task = task.update_from_form(completed: '0')
      expect(updated_task.is_a?(described_class)).to be true
    end
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

    it 'should turn completed "0" to completed_at nil' do
      attrs = { completed: '0' }
      transmorgrified = described_class.transmorgrify_completed(attrs)
      expect(transmorgrified).to eq(completed_at: nil)
    end
  end
end
