# encoding: utf-8
class FormField2 < ActiveRecord::Base
  has_fields do |f|
    f.string :string, :ru => 'Атрибут', :en => 'Attribute'
  end
end
