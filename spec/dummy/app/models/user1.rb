class User1 < ActiveRecord::Base
  validates :login, :presence => true

  has_fields do |f|
    f.string :login
  end
end
