class CommentSerializer < ActiveModel::Serializer
  attributes :id

  has_one :user
end
