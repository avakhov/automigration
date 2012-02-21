module Automigration
  module Fields
    class Boolean < Sys::Base
      def to_db_columns
        [db_column_for_standart_types(:default => !!@options[:default])]
      end

      def edit(template, object, object_name)
        edit_wrapper template, object, object_name do
          template.check_box(object_name, name, :object => object)
        end
      end

      def show(template, object, object_name)
        show_wrapper template, object, object_name do
          if object.send(@name)
            'yes'
          else
            'no'
          end
        end
      end
    end
  end
end
