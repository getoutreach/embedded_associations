class PostSerializer < ActiveModel::Serializer
  attributes :id, :title

  has_one :user
  has_one :category
  has_many :comments
  has_many :tags
end
