# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)

require 'csv'

# Added to measure seeding times
starting = Process.clock_gettime(Process::CLOCK_MONOTONIC)

street_cafes = []
CSV.foreach('./Street Cafes 2020-21.csv', headers: true, header_converters: :symbol) do |data|
  street_cafes << StreetCafe.new(name: data[:cafrestaurant_name], address: data[:street_address], post_code: data[:post_code], num_chairs: data[:number_of_chairs])
end
StreetCafe.import(street_cafes)
ActiveRecord::Base.connection.reset_pk_sequence!('street_cafes')

ending = Process.clock_gettime(Process::CLOCK_MONOTONIC)
elapsed = ending - starting
puts "\nSuccess! Took #{elapsed.round(2)} seconds to seed the database.\n\n"
