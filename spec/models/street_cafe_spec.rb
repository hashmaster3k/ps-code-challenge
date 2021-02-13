require 'rails_helper'

RSpec.describe StreetCafe, type: :model do
  describe 'validations' do
    it { should validate_presence_of :name }
    it { should validate_presence_of :address }
    it { should validate_presence_of :post_code }
    it { should validate_presence_of :num_chairs }
  end

  describe 'instantiation' do
    it 'can create a new object' do
      StreetCafe.create(
        name: 'Sovereign Light Cafe',
        address: '123 Keane Street',
        post_code: 'LS1 1AA',
        num_chairs: 42
      )

      expect(StreetCafe.count).to eq(1)
    end

    it 'cannot create a new object with missing name' do
      StreetCafe.create(
        address: '123 Keane Street',
        post_code: 'LS1 1AA',
        num_chairs: 42
      )

      expect(StreetCafe.count).to eq(0)
    end

    it 'cannot create a new object with missing address' do
      StreetCafe.create(
        name: 'Sovereign Light Cafe',
        post_code: 'LS1 1AA',
        num_chairs: 42
      )

      expect(StreetCafe.count).to eq(0)
    end

    it 'cannot create a new object with missing post code' do
      StreetCafe.create(
        name: 'Sovereign Light Cafe',
        address: '123 Keane Street',
        num_chairs: 42
      )

      expect(StreetCafe.count).to eq(0)
    end

    it 'cannot create a new object with missing number of chairs' do
      StreetCafe.create(
        name: 'Sovereign Light Cafe',
        address: '123 Keane Street',
        post_code: 'LS1 1AA'
      )

      expect(StreetCafe.count).to eq(0)
    end
  end
end
