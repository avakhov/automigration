module Automigration
  module Fields
    class Text < Sys::Base
      def to_db_columns
        [db_column_for_standart_types]
      end

      def edit(template, object, object_name)
        edit_wrapper template, object, object_name do
          template.text_area(object_name, name, :object => object)
        end
      end
    end
  end
end
