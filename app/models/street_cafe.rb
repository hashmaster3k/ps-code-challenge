class StreetCafe < ApplicationRecord
  validates :name, :address, :post_code, :num_chairs, presence: true
end
