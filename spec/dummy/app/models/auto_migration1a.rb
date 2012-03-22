class AutoMigration1a < ActiveRecord::Base
  add_field :integer, :additional_field

  has_fields do
    integer :integer_field
  end
end
