class AutoMigration2 < ActiveRecord::Base
  migration_attr :some_attr1, :some_attr2
  migration_attr :some_attr3

  has_fields do |f|
    f.integer :integer_field
  end
end
