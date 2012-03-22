class AutoMigration1a < ActiveRecord::Base
  add_field :integer, :additional_field

  has_fields do |f|
    f.integer :integer_field
  end
end
