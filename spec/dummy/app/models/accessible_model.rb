class AccessibleModel < ActiveRecord::Base
  has_fields do
    integer :first, :default => 0
    integer :second, :default => 0, :accessible => false
  end
end
