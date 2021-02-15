require 'rails_helper'
require 'csv'

RSpec.describe 'Post Code Info View' do
  describe 'Test Sample Data' do
    before :each do
      street_cafes = []
      CSV.foreach('./spec/fixtures/test_data.csv', headers: true, header_converters: :symbol) do |data|
        street_cafes << StreetCafe.new(name: data[:cafrestaurant_name], address: data[:street_address], post_code: data[:post_code], num_chairs: data[:number_of_chairs])
      end
      StreetCafe.import(street_cafes)
      ActiveRecord::Base.connection.reset_pk_sequence!('street_cafes')
    end

    it 'should have display only unique postal codes' do
      num_unique_post_codes = StreetCafe.select(:post_code).distinct.count
      results = PostCodeInfo.count
      expect(results). to eq(num_unique_post_codes)
    end

    it 'should match data with individual queries' do
      results_reg = StreetCafe.where("post_code = ?", "LS1 5EL")
      results_view = PostCodeInfo.where("post_code = ?", "LS1 5EL").first

      total_chairs = 0

      results_reg.each do |result|
        total_chairs += result[:num_chairs]
      end

      expect(results_reg.count).to eq(results_view[:total_count])
      expect(total_chairs).to eq(results_view[:total_chairs])

      hotel_chocolat = results_reg.max_by { |result| result[:num_chairs] }

      expect(results_view.place_with_max_chairs).to eq(hotel_chocolat.name)
      expect(results_view.max_chairs).to eq(hotel_chocolat.num_chairs)
    end
  end
end
