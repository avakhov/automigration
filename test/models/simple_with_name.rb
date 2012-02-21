class SimpleWithName < ActiveRecord::Base
  has_fields do |f|
    f.string :name
  end
end
