require 'rails_helper'

RSpec.describe Constellation, type: :model do
  it 'has a valid factory' do
    expect(FactoryBot.build(:constellation)).to be_valid
  end

  describe 'associations' do
    it { is_expected.to belong_to(:region).required }
    it { is_expected.to have_many(:stars) }
  end
end
