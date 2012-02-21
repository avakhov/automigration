class Searchable < ActiveRecord::Base
  has_fields do |t|
    t.string :title
    t.text :body
  end
end
