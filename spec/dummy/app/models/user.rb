class User < ActiveRecord::Base
  devise :database_authenticatable, :registerable, :recoverable, :rememberable, :trackable, :validatable

  has_fields do |t|
    t.devise_database_authenticatable :null => false
    t.devise_recoverable
    t.devise_rememberable
    t.devise_trackable
  end
end
