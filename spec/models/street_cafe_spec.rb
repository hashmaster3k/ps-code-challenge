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

  describe 'class methods' do
    before :each do
      StreetCafe.create!(
        name: 'Cafe 1',
        address: '1',
        post_code: 'LS1 123',
        num_chairs: 5, category: 'ls1 small')
      StreetCafe.create!(
        name: 'Cafe 2',
        address: '2',
        post_code: 'LS1 234',
        num_chairs: 10, category: 'ls1 medium')
      StreetCafe.create!(
        name: 'Cafe 3',
        address: '3',
        post_code: 'LS1 345',
        num_chairs: 100,
        category: 'ls1 large')
      StreetCafe.create!(
        name: 'Cafe 4',
        address: '4',
        post_code: 'LS2 456',
        num_chairs: 6,
        category: 'ls2 small')
      StreetCafe.create!(
        name: 'Cafe 5',
        address: '5',
        post_code: 'LS2 567',
        num_chairs: 9,
        category: 'ls2 small')
      StreetCafe.create!(
        name: 'Cafe 6',
        address: '6',
        post_code: 'LS2 678',
        num_chairs: 30,
        category: 'ls2 large')
      StreetCafe.create!(
        name: 'Cafe 7',
        address: '7',
        post_code: 'LS2 890',
        num_chairs: 145,
        category: 'ls2 large')
      StreetCafe.create!(
        name: 'Cafe 8',
        address: '8',
        post_code: 'LS9 123',
        num_chairs: 42,
        category: 'other')
    end

    it 'gets all medium and large cafes' do
      expect(StreetCafe.find_medium_large_cafes.count).to eq(4)
    end

    it 'gets all small cafes' do
      expect(StreetCafe.find_small_cafes.count).to eq(3)
    end

    it 'deletes an array of given cafes' do
      expect(StreetCafe.count).to eq(8)
      StreetCafe.delete_cafes(StreetCafe.all)
      expect(StreetCafe.count).to eq(0)
    end
  end
end
