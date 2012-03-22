class AutoMigration3 < ActiveRecord::Base
  has_fields :timestamps => false do |f|
    f.integer :integer_field
  end
end
