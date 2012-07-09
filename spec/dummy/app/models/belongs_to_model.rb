class BelongsToModel < ActiveRecord::Base
  has_fields do |f|
    f.string :name

    f.belongs_to :simple, :accessible => true
    f.belongs_to :some, :class_name => 'Simple', :accessible => true
    f.belongs_to :parent, :class_name => 'BelongsToModel', :accessible => true
  end
end
