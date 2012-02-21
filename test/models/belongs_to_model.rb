class BelongsToModel < ActiveRecord::Base
  has_fields do |f|
    f.string :name

    f.belongs_to :simple
    f.belongs_to :some, :class_name => 'Simple'
    f.belongs_to :parent, :class_name => 'BelongsToModel'
  end
end
