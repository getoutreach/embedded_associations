class Post < ActiveRecord::Base
  attr_accessible :title

  has_many :comments, autosave: true, dependent: :destroy
  has_many :tags, autosave: true, dependent: :destroy
  belongs_to :category, autosave: true, dependent: :destroy
  belongs_to :user, autosave: true, dependent: :destroy
end
