class Tag < ActiveRecord::Base
  belongs_to :post

  validates :name, uniqueness: true, allow_blank: true
end
