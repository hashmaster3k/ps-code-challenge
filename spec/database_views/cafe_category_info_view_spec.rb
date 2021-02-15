require 'rails_helper'
require 'csv'

Rails.application.load_tasks

RSpec.describe 'Cafe Category Info View' do
  after(:all) do
    Rake::Task["street_cafes:categorize"].reenable
  end

  describe 'Test Sample Data' do
    before :each do
      street_cafes = []
      CSV.foreach('./spec/fixtures/test_data.csv', headers: true, header_converters: :symbol) do |data|
        street_cafes << StreetCafe.new(name: data[:cafrestaurant_name], address: data[:street_address], post_code: data[:post_code], num_chairs: data[:number_of_chairs])
      end
      StreetCafe.import(street_cafes)
      ActiveRecord::Base.connection.reset_pk_sequence!('street_cafes')
    end

    it 'should display six unique categories' do
      Rake::Task["street_cafes:categorize"].invoke

      results = CafeCategoryInfo.pluck(:category)
      expect(results.count).to eq(6)
      expect(results.uniq.count).to eq(6)
    end
  end
end
