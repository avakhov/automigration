class AutoMigration1 < ActiveRecord::Base
  has_fields do |f|
    f.integer :integer_field
    f.float :float_field
    f.boolean :boolean_field
    f.string :string_field
    f.text :text_field
    f.datetime :datetime_field
    f.date :date_field
    f.time :time_field
  end

  add_field :integer, :additional_field
end
