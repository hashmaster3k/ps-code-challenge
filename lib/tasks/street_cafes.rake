require './lib/helpers/statistical.rb'
require 'csv'

namespace :street_cafes do
  desc "Categorize empty cafes based on number of chairs"
  task categorize: :environment do
    include Statistical

    cafes = StreetCafe.where(category: nil)
    cafes_LS1 = []
    cafes_LS2 = []

    cafes.map do |cafe|
      if cafe.post_code.split(' ').first == "LS1"
        cafes_LS1 << cafe
      elsif cafe.post_code.split(' ').first == "LS2"
        cafes_LS2 << cafe
      else
        cafe.category = 'other'
        cafe.save
      end
    end

    unless cafes_LS1.empty?
      cafes_LS1.each do |cafe|
        if cafe.num_chairs >= 100
          cafe.category = 'ls1 large'
        elsif cafe.num_chairs >= 10
          cafe.category = 'ls1 medium'
        else
          cafe.category = 'ls1 small'
        end

        cafe.save
      end
    end

    unless cafes_LS2.empty?
      values = cafes_LS2.pluck(:num_chairs)
      percentile_50_LS2 = percentile(values, 0.5)

      cafes_LS2.each do |cafe|
        if cafe.num_chairs >= percentile_50_LS2
          cafe.category = 'ls2 large'
        else
          cafe.category = 'ls2 small'
        end

        cafe.save
      end
    end
  end

  desc "Exports cafes with categories labeled small to a csv and deletes the records"
  task export_small_cafes: :environment do
    cafes = StreetCafe.find_small_cafes
    headers = ['Café/Restaurant Name', 'Street Address', 'Post Code', 'Number of Chairs']
    file = "#{Rails.root}/exported_data/list_small_cafes.csv"

    CSV.open(file, 'w', write_headers: true, headers: headers) do |writer|
      cafes.each do |cafe|
        writer << [cafe.name, cafe.address, cafe.post_code, cafe.num_chairs]
      end
    end

    StreetCafe.delete_cafes(cafes)
  end
end
