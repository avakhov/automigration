class BelongsToModel < ActiveRecord::Base
  has_fields do |f|
    f.string :name

    f.belongs_to :simple
    f.belongs_to :some, :class_name => 'Simple'
    f.belongs_to :parent, :class_name => 'BelongsToModel'
    f.belongs_to :simple_with_name
    f.belongs_to :simple_allow_blank, :class_name => 'Simple', :allow_blank => true

    f.belongs_to :simple_with_get_all0, :class_name => 'Simple',
      :get_all => Proc.new { [Simple.order('id DESC').first] }

    f.belongs_to :simple_with_get_all1, :class_name => 'Simple',
      :get_all => Proc.new { |obj| obj.name == 'all' ? Simple.all : [Simple.order(:id).first] }

    f.belongs_to :simple_with_to_title1, :class_name => 'Simple',
      :to_title => Proc.new { |obj| obj.id }

    f.belongs_to :simple_with_to_title2, :class_name => 'Simple',
      :to_title => Proc.new { |obj, this| obj.id + this.id }
  end
end
