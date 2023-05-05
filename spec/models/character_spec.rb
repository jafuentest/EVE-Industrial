require 'rails_helper'

RSpec.describe Character, type: :model do
  it 'has a valid factory' do
    expect(FactoryBot.build(:character)).to be_valid
  end

  describe '#verification_data' do
    it 'sets character attributes from access_token verification response' do
      character = FactoryBot.build(:character, :without_verification_data)
      character.verification_data = data_hash = {
        'CharacterName' => 'Seifer Fontaine',
        'Scopes' => 'esi-markets.read_character_orders.v1 esi-markets.read_corporation_orders.v1',
        'TokenType' => 'Character',
        'CharacterOwnerHash' => 'SomeVeryLongAlphanumeric123=',
        'ExpiresOn' => '2017-07-05T14:34:16.5857101'
      }

      expect(character.character_name).to eq(data_hash['CharacterName'])
      expect(character.scopes).to eq(data_hash['Scopes'])
      expect(character.token_type).to eq(data_hash['TokenType'])
      expect(character.owner_hash).to eq(data_hash['CharacterOwnerHash'])
      expect(character.esi_expires_on).to eq(DateTime.parse(data_hash['ExpiresOn']))
    end
  end
end
