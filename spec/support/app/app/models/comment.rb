class Comment < ActiveRecord::Base
  belongs_to :post
  belongs_to :user, autosave: true, dependent: :destroy
end
