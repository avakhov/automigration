class AutoMigration3 < ActiveRecord::Base
  has_fields :timestamps => false do
    integer :integer_field
  end
end
