require 'rails_helper'

RSpec.describe Region, type: :model do
  it 'has a valid factory' do
    expect(FactoryBot.build(:region)).to be_valid
  end

  describe 'associations' do
    it { is_expected.to have_many(:constellations) }
    it { is_expected.to have_many(:stars) }
  end
end
