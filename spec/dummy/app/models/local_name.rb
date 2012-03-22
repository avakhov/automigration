class LocalName < ActiveRecord::Base
  has_fields do |f|
    f.integer :value
  end
end
