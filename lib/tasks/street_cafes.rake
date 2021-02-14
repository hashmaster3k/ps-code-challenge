namespace :street_cafes do
  desc "Categorize Empty Cafes Based on Number of Chairs"
  task categorize: :environment do
    starting = Process.clock_gettime(Process::CLOCK_MONOTONIC)

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

    average_chairs_LS2 = cafes_LS2.sum { |cafe| cafe.num_chairs } / cafes_LS2.count

    cafes_LS2.each do |cafe|
      if cafe.num_chairs >= average_chairs_LS2
        cafe.category = 'ls2 large'
      else
        cafe.category = 'ls2 small'
      end

      cafe.save
    end
    
    ending = Process.clock_gettime(Process::CLOCK_MONOTONIC)
    elapsed = ending - starting
    puts "\nSuccess! Took #{elapsed.round(2)} seconds to categorize the resource.\n\n"
  end



end
