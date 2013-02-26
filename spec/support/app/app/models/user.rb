class User < ActiveRecord::Base
  attr_accessible :name, :email

  has_one :account, autosave: true, dependent: :destroy
  has_many :posts
  has_many :comments
end
