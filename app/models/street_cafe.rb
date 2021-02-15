class StreetCafe < ApplicationRecord
  validates :name, :address, :post_code, :num_chairs, presence: true

  def self.find_small_cafes
    cafes = where('category != ?', 'other').or(where.not(category: nil))
    small_cafes = []

    cafes.each do |cafe|
      category = cafe.category.split(' ').second
      small_cafes << cafe if category == 'small'
    end

    small_cafes
  end

  def self.delete_cafes(list_cafes)
    ids = list_cafes.pluck(:id)
    destroy(ids)
  end
end
