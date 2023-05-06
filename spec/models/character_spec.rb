require 'rails_helper'

RSpec.describe Character, type: :model do
  it 'has a valid factory' do
    expect(FactoryBot.build(:character)).to be_valid
  end

  describe '#verification_data' do
    it 'sets character attributes from access_token verification response' do
      character = FactoryBot.build(:character, :without_verification_data)
      character.verification_data = data_hash = {
        'CharacterName' => 'Test Character',
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

  describe '#auth_token' do
    context 'when token is fresh' do
      it 'returns existing token' do
        character = FactoryBot.build(:character)

        expect(ESI).not_to receive(:authenticate)
        character.auth_token
      end
    end

    context 'when token is expired' do
      it 'calls the ESI for a new token' do
        character = FactoryBot.build(:character, esi_expires_on: DateTime.now)
        access_token = Time.now.to_i.to_s
        allow(ESI).to receive(:authenticate).and_return(
          {
            'token_type' => 'Bearer',
            'expires_in' => 1199,
            'access_token' => access_token,
            'refresh_token' => 'NotSoLongAlphanumeric1=='
          }
        )

        expect(character.auth_token).to eq(access_token)
      end
    end
  end

  describe '#avatar' do
    context 'When character already has a persisted potrait' do
      it 'returns the existing potrait URL' do
        avatar_url = "https://url/portrait#{Time.now.to_i}/portrait?size=64"
        character = FactoryBot.build(:character, character_portrait: avatar_url)

        expect(character.avatar).to eq(avatar_url)
      end
    end

    context 'When character already has no potrait' do
      it 'calls the ESI for portrait data' do
        character = FactoryBot.build(:character, character_portrait: nil)
        api_response = [64, 128, 256, 512]
          .each_with_object({}) { |i, h| h["px#{i}x#{i}"] = "https://url/portrait?size=#{i}" }
        allow(ESI).to receive(:fetch_character_portrait).and_return(api_response)

        expect(character.avatar).to eq(api_response['px64x64'])
      end
    end
  end
end
