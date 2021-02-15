require 'rails_helper'

RSpec.describe 'Street Cafe Concatenate Category to Cafe Name Task' do
  it 'should concat category to front of cafe name' do
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

    Rake::Task["street_cafes:concat_medium_large_cafes"].execute

    cafes = StreetCafe.find_medium_large_cafes
    cafes.each do |cafe|
      name = cafe.name.split[2] + " " + cafe.name.split[3]
      expect(cafe.name).to eq("#{cafe.category} #{name}")
    end
  end
end
