class User < ActiveRecord::Base
  has_one :account, autosave: true, dependent: :destroy
  has_many :posts
  has_many :comments
end
