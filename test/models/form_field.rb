class FormField < ActiveRecord::Base
  has_fields do |f|
    f.string :string
    f.integer :integer
  end
end
