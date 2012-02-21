module Automigration
  module Fields
    class Password < Sys::Base
      def to_db_columns
        [db_column_for_standart_types(:type => :string)]
      end
    end
  end
end
