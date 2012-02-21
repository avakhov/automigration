module Automigration
  module Fields
    class Boolean < Sys::Base
      def to_db_columns
        [db_column_for_standart_types(:default => !!@options[:default])]
      end
    end
  end
end
