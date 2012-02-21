class AccessibleModel < ActiveRecord::Base
  has_fields do |f|
    f.integer :first, :default => 0
    f.integer :second, :default => 0, :accessible => false
  end
end
