module Automigration
  module Fields
    class BelongsTo < Sys::Base
      def to_db_columns
        [db_column_for_standart_types(:type => :integer, :name => "#{@name}_id")]
      end

      def extend_model!(model)
        super

        model.belongs_to @name,
          :class_name => @options[:class_name],
          :inverse_of => @options[:inverse_of]

        if @options[:accessible]
          model.attr_accessible "#{@name}_id"
        end
      end

      def assert_options!
        raise "wrong name '#{@name}'" if @name =~ /_id$/
      end

      def valid_options_keys
        super + [:class_name, :inverse_of]
      end
    end
  end
end
