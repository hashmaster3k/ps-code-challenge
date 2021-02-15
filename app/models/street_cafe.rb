class StreetCafe < ApplicationRecord
  validates :name, :address, :post_code, :num_chairs, presence: true

  def self.find_medium_large_cafes
    where('category LIKE ? OR category LIKE ?', "%medium%", "%large%")
  end

  def self.find_small_cafes
    where('category LIKE ?', "%small%")
  end

  def self.delete_cafes(list_cafes)
    ids = list_cafes.pluck(:id)
    destroy(ids)
  end
end
