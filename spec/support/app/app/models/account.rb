class Account < ActiveRecord::Base
  attr_accessible :note
  belongs_to :user
end
