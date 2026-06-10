require 'rails_helper'

RSpec.describe Character, type: :model do
  it 'has a valid factory' do
    expect(FactoryBot.build(:character)).to be_valid
  end

  describe 'associations' do
    it { is_expected.to belong_to(:user).required }
    it { is_expected.to have_many(:industry_jobs) }
    it { is_expected.to have_many(:orders) }
    it { is_expected.to have_many(:planetary_colonies) }
  end

  describe '#verification_data=' do
    let(:data_hash) do
      {
        'CharacterName' => 'Test Character',
        'Scopes' => 'esi-markets.read_character_orders.v1 esi-markets.read_corporation_orders.v1',
        'TokenType' => 'Character',
        'CharacterOwnerHash' => 'SomeVeryLongAlphanumeric123=',
        'ExpiresOn' => '2017-07-05T14:34:16.5857101'
      }
    end
    let(:character) { FactoryBot.build(:character, :without_verification_data) }

    before { character.verification_data = data_hash }

    it 'sets character_name' do
      expect(character.character_name).to eq(data_hash['CharacterName'])
    end

    it 'sets scopes' do
      expect(character.scopes).to eq(data_hash['Scopes'])
    end

    it 'sets token_type' do
      expect(character.token_type).to eq(data_hash['TokenType'])
    end

    it 'sets owner_hash' do
      expect(character.owner_hash).to eq(data_hash['CharacterOwnerHash'])
    end

    it 'sets esi_expires_on' do
      expect(character.esi_expires_on).to eq(DateTime.parse(data_hash['ExpiresOn']))
    end
  end

  describe '#auth_token' do
    context 'when token is fresh' do
      let(:character) { FactoryBot.build(:character) }

      it 'returns existing token' do
        allow(ESI).to receive(:authenticate)
        character.auth_token
        expect(ESI).not_to have_received(:authenticate)
      end
    end

    context 'when token is expired' do
      let(:character) { FactoryBot.build(:character, esi_expires_on: DateTime.now) }
      let(:access_token) { SecureRandom.alphanumeric }

      before do
        allow(ESI).to receive(:authenticate).and_return(
          'token_type' => 'Bearer',
          'expires_in' => 1199,
          'access_token' => access_token,
          'refresh_token' => 'NotSoLongAlphanumeric1=='
        )
      end

      it 'calls the ESI for a new token' do
        expect(character.auth_token).to eq(access_token)
      end
    end

    context 'when the token is refreshed successfully' do
      let(:character) { FactoryBot.create(:character, esi_expires_on: DateTime.now, reauth_required: true) }

      before do
        allow(ESI).to receive(:authenticate).and_return(
          'token_type' => 'Bearer',
          'expires_in' => 1199,
          'access_token' => 'fresh_access_token',
          'refresh_token' => 'fresh_refresh_token'
        )
      end

      it 'persists the new access token' do
        character.auth_token
        expect(character.reload.esi_auth_token).to eq('fresh_access_token')
      end

      it 'clears the re-auth flag' do
        expect { character.auth_token }.to change { character.reload.reauth_required }.from(true).to(false)
      end
    end

    context 'when the refresh fails' do
      let(:character) { FactoryBot.create(:character, esi_expires_on: DateTime.now) }

      before { allow(ESI).to receive(:authenticate).and_return(nil) }

      it 'returns nil' do
        expect(character.auth_token).to be_nil
      end

      it 'flags the character for re-authentication' do
        expect { character.auth_token }.to change { character.reload.reauth_required }.from(false).to(true)
      end
    end
  end

  describe '#avatar' do
    context 'when character already has a persisted portrait' do
      let(:avatar_url) { 'https://url/portrait/character_id/portrait?size=64' }
      let(:character) { FactoryBot.build(:character, character_portrait: avatar_url) }

      it 'returns the existing potrait URL' do
        expect(character.avatar).to eq(avatar_url)
      end
    end

    context 'when character has no portrait' do
      let(:character) { FactoryBot.build(:character, character_portrait: nil) }
      let(:api_response) do
        [64, 128, 256, 512].to_h do |i|
          ["px#{i}x#{i}", "https://url/portrait?size=#{i}"]
        end
      end

      it 'calls the ESI for portrait data' do
        allow(ESI).to receive(:fetch_character_portrait).and_return(api_response)
        expect(character.avatar).to eq(api_response['px64x64'])
      end
    end
  end
end
