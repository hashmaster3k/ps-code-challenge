require 'rails_helper'

RSpec.describe 'Street Cafe Categorize Task' do
  it 'should categorize properly' do
    cafe1 = StreetCafe.create!(name: 'Cafe 1', address: '1', post_code: 'LS1 123', num_chairs: 5).id
    cafe2 = StreetCafe.create!(name: 'Cafe 2', address: '2', post_code: 'LS1 234', num_chairs: 10).id
    cafe3 = StreetCafe.create!(name: 'Cafe 3', address: '3', post_code: 'LS1 345', num_chairs: 100).id
    cafe4 = StreetCafe.create!(name: 'Cafe 4', address: '4', post_code: 'LS2 456', num_chairs: 6).id
    cafe5 = StreetCafe.create!(name: 'Cafe 5', address: '5', post_code: 'LS2 567', num_chairs: 9).id
    cafe6 = StreetCafe.create!(name: 'Cafe 6', address: '6', post_code: 'LS2 678', num_chairs: 30).id
    cafe7 = StreetCafe.create!(name: 'Cafe 7', address: '7', post_code: 'LS2 890', num_chairs: 145).id
    cafe8 = StreetCafe.create!(name: 'Cafe 8', address: '8', post_code: 'LS9 123', num_chairs: 42).id

    StreetCafe.all.each do |cafe|
      expect(cafe.category).to be nil
    end

    Rake::Task["street_cafes:categorize"].execute

    expect(StreetCafe.find(cafe1).category).to eq('ls1 small')
    expect(StreetCafe.find(cafe2).category).to eq('ls1 medium')
    expect(StreetCafe.find(cafe3).category).to eq('ls1 large')
    expect(StreetCafe.find(cafe4).category).to eq('ls2 small')
    expect(StreetCafe.find(cafe5).category).to eq('ls2 small')
    expect(StreetCafe.find(cafe6).category).to eq('ls2 large')
    expect(StreetCafe.find(cafe7).category).to eq('ls2 large')
    expect(StreetCafe.find(cafe8).category).to eq('other')
  end
end
