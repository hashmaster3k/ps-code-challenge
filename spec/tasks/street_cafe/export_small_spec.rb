require 'rails_helper'

RSpec.describe 'Street Cafe Export Small Cafes Task' do
  it 'should export to csv with correct data' do
    cafe1 = StreetCafe.create!(
      name: 'Cafe 1',
      address: '1',
      post_code: 'LS1 123',
      num_chairs: 5, category: 'ls1 small')
    cafe2 = StreetCafe.create!(
      name: 'Cafe 2',
      address: '2',
      post_code: 'LS1 234',
      num_chairs: 10, category: 'ls1 medium')
    cafe3 = StreetCafe.create!(
      name: 'Cafe 3',
      address: '3',
      post_code: 'LS1 345',
      num_chairs: 100,
      category: 'ls1 large')
    cafe4 = StreetCafe.create!(
      name: 'Cafe 4',
      address: '4',
      post_code: 'LS2 456',
      num_chairs: 6,
      category: 'ls2 small')
    cafe5 = StreetCafe.create!(
      name: 'Cafe 5',
      address: '5',
      post_code: 'LS2 567',
      num_chairs: 9,
      category: 'ls2 small')
    cafe6 = StreetCafe.create!(
      name: 'Cafe 6',
      address: '6',
      post_code: 'LS2 678',
      num_chairs: 30,
      category: 'ls2 large')
    cafe7 = StreetCafe.create!(
      name: 'Cafe 7',
      address: '7',
      post_code: 'LS2 890',
      num_chairs: 145,
      category: 'ls2 large')
    cafe8 = StreetCafe.create!(
      name: 'Cafe 8',
      address: '8',
      post_code: 'LS9 123',
      num_chairs: 42,
      category: 'other')

    Rake::Task["street_cafes:export_small_cafes"].execute

    cafes = []
    CSV.foreach('./spec/fixtures/list_small_cafes.csv', headers: true, header_converters: :symbol) do |cafe|
      cafes << { name: cafe[:cafrestaurant_name], address: cafe[:street_address], post_code: cafe[:post_code], num_chairs: cafe[:number_of_chairs] }
    end

    expect(cafes.count).to eq(3)

    cafe_1 = cafes[0]
    cafe_4 = cafes[1]
    cafe_5 = cafes[2]

    expect(cafe_1[:name]).to eq(cafe1.name)
    expect(cafe_1[:address]).to eq(cafe1.address)
    expect(cafe_1[:post_code]).to eq(cafe1.post_code)
    expect(cafe_1[:num_chairs].to_i).to eq(cafe1.num_chairs)
    expect(cafe_4[:name]).to eq(cafe4.name)
    expect(cafe_4[:address]).to eq(cafe4.address)
    expect(cafe_4[:post_code]).to eq(cafe4.post_code)
    expect(cafe_4[:num_chairs].to_i).to eq(cafe4.num_chairs)
    expect(cafe_5[:name]).to eq(cafe5.name)
    expect(cafe_5[:address]).to eq(cafe5.address)
    expect(cafe_5[:post_code]).to eq(cafe5.post_code)
    expect(cafe_5[:num_chairs].to_i).to eq(cafe5.num_chairs)
  end
end
