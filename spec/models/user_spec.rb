require 'rails_helper'

RSpec.describe User, type: :model do
  it 'has a valid factory' do
    expect(FactoryBot.build(:user)).to be_valid
  end

  describe 'associations' do
    it { is_expected.to have_many(:characters).dependent(:destroy) }
    it { is_expected.to have_many(:industry_jobs).through(:characters) }
    it { is_expected.to have_many(:orders).through(:characters) }
  end

  describe '#verification_data=' do
    let(:data_hash) do
      {
        'CharacterName' => 'Test Character',
        'Scopes' => 'esi-markets.read_character_orders.v1',
        'TokenType' => 'Character',
        'CharacterOwnerHash' => 'SomeVeryLongAlphanumeric123=',
        'ExpiresOn' => '2017-07-05T14:34:16.5857101'
      }
    end
    let(:user) { FactoryBot.build(:user) }

    before { user.verification_data = data_hash }

    it 'sets character_name' do
      expect(user.character_name).to eq(data_hash['CharacterName'])
    end

    it 'sets scopes' do
      expect(user.scopes).to eq(data_hash['Scopes'])
    end

    it 'sets token_type' do
      expect(user.token_type).to eq(data_hash['TokenType'])
    end

    it 'sets owner_hash' do
      expect(user.owner_hash).to eq(data_hash['CharacterOwnerHash'])
    end

    it 'sets esi_expires_on' do
      expect(user.esi_expires_on).to eq(DateTime.parse(data_hash['ExpiresOn']))
    end
  end

  describe '.find_or_register' do
    subject(:find_or_register) { described_class.find_or_register('auth-code') }

    let(:auth_response) do
      { 'access_token' => 'access-token', 'refresh_token' => 'refresh-token' }
    end
    let(:verification_data) do
      {
        'CharacterID' => 9001,
        'CharacterName' => 'Capsuleer',
        'Scopes' => 'esi-markets.read_character_orders.v1',
        'TokenType' => 'Character',
        'CharacterOwnerHash' => 'OwnerHash==',
        'ExpiresOn' => '2026-05-20T12:00:00'
      }
    end

    before do
      allow(ESI).to receive(:authenticate).with('auth-code').and_return(auth_response)
      allow(ESI).to receive(:verify_access_token).with('access-token').and_return(verification_data)
    end

    it 'creates a user for the verified character' do
      expect { find_or_register }.to change(described_class, :count).by(1)
    end

    it 'persists the auth tokens and character id' do
      expect(find_or_register).to have_attributes(
        character_id: 9001,
        esi_auth_token: 'access-token',
        esi_refresh_token: 'refresh-token'
      )
    end

    it 'reuses an existing user with the same character id' do
      FactoryBot.create(:user, character_id: 9001)
      expect { find_or_register }.not_to change(described_class, :count)
    end
  end

  describe '.add_character' do
    subject(:add_character) { described_class.add_character('auth-code', user.id) }

    let(:user) { FactoryBot.create(:user) }
    let(:auth_response) do
      { 'access_token' => 'access-token', 'refresh_token' => 'refresh-token' }
    end
    let(:verification_data) do
      {
        'CharacterID' => 9002,
        'CharacterName' => 'Alt Capsuleer',
        'Scopes' => 'esi-markets.read_character_orders.v1',
        'TokenType' => 'Character',
        'CharacterOwnerHash' => 'OwnerHash==',
        'ExpiresOn' => '2026-05-20T12:00:00'
      }
    end

    before do
      allow(ESI).to receive(:authenticate).with('auth-code').and_return(auth_response)
      allow(ESI).to receive(:verify_access_token).with('access-token').and_return(verification_data)
    end

    it 'creates a character' do
      expect { add_character }.to change(Character, :count).by(1)
    end

    it 'associates the character with the user' do
      expect(add_character.user_id).to eq(user.id)
    end
  end

  describe '#auth_token' do
    context 'when the token is fresh' do
      let(:user) { FactoryBot.build(:user, esi_auth_token: 'fresh', esi_expires_on: DateTime.now + 10.minutes) }

      it 'returns the existing token without re-authenticating' do
        allow(ESI).to receive(:authenticate)
        user.auth_token
        expect(ESI).not_to have_received(:authenticate)
      end
    end

    context 'when the token is expired' do
      let(:user) { FactoryBot.build(:user, esi_refresh_token: 'old-refresh', esi_expires_on: DateTime.now) }

      before do
        allow(ESI).to receive(:authenticate).with('old-refresh', refresh: true)
          .and_return('access_token' => 'new-access', 'refresh_token' => 'new-refresh')
      end

      it 'returns a refreshed access token' do
        expect(user.auth_token).to eq('new-access')
      end

      it 'updates the refresh token' do
        user.auth_token
        expect(user.esi_refresh_token).to eq('new-refresh')
      end
    end
  end

  describe '#avatar' do
    context 'when the user already has a portrait' do
      let(:user) { FactoryBot.build(:user, character_portrait: 'https://url/portrait?size=64') }

      it 'returns the existing portrait URL' do
        expect(user.avatar).to eq('https://url/portrait?size=64')
      end
    end

    context 'when the user has no portrait' do
      let(:user) { FactoryBot.create(:user, character_portrait: nil) }
      let(:portraits) { { 'px64x64' => 'https://url/fetched?size=64' } }

      before { allow(ESI).to receive(:fetch_character_portrait).and_return(portraits) }

      it 'fetches and persists the portrait' do
        expect(user.avatar).to eq('https://url/fetched?size=64')
      end
    end
  end

  describe '#remember_me' do
    it 'defaults to true when unset' do
      expect(FactoryBot.build(:user).remember_me).to be(true)
    end

    it 'returns the assigned value when set' do
      user = FactoryBot.build(:user)
      user.remember_me = false
      expect(user.remember_me).to be(false)
    end
  end

  describe '#update_market_orders' do
    let(:user) { FactoryBot.create(:user) }
    let(:character) { FactoryBot.create(:character, user:) }

    before do
      character
      allow(Order).to receive(:update_character_orders)
    end

    it 'refreshes orders for each character' do
      user.update_market_orders
      expect(Order).to have_received(:update_character_orders).with(character)
    end
  end

  describe '#update_industry_jobs' do
    let(:user) { FactoryBot.create(:user) }
    let(:character) { FactoryBot.create(:character, user:) }

    before do
      character
      allow(IndustryJob).to receive(:update_character_jobs)
    end

    it 'updates industry jobs for each character' do
      user.update_industry_jobs
      expect(IndustryJob).to have_received(:update_character_jobs).with(character)
    end
  end

  describe '#update_planetary_colonies' do
    let(:user) { FactoryBot.create(:user) }
    let(:character) { FactoryBot.create(:character, user:) }

    before do
      character
      allow(PlanetaryColony).to receive(:update_character_colonies)
    end

    it 'updates planetary colonies for each character' do
      user.update_planetary_colonies
      expect(PlanetaryColony).to have_received(:update_character_colonies).with(character)
    end
  end
end
