module Automigration
  module Fields
    class String < Sys::Base
      def to_db_columns
        [db_column_for_standart_types]
      end
    end
  end
end
