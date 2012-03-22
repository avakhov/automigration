class Simple < ActiveRecord::Base
  has_fields do |f|
    f.boolean :boolean
  end
end
