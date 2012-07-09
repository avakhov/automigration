class AccessibleModel < ActiveRecord::Base
  has_fields do
    integer :first, :default => 0, :accessible => true
    integer :second, :default => 0
  end
end
