module Automigration
  module Fields
    class Password < Sys::Base
      def to_db_columns
        [db_column_for_standart_types(:type => :string)]
      end

      def edit(template, object, object_name)
        edit_wrapper template, object, object_name do
          template.password_field(object_name, name, :object => object)
        end
      end
    end
  end
end
