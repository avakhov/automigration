class AutoMigration1 < ActiveRecord::Base
  attr_accessible :string_field, :integer_field

  has_fields do
    integer :integer_field
    float :float_field
    boolean :boolean_field
    string :string_field
    text :text_field
    datetime :datetime_field
    date :date_field
    time :time_field
  end

  add_field :integer, :additional_field
end
