class BooleanModel < ActiveRecord::Base
  has_fields do |f|
    f.boolean :value
  end
end
