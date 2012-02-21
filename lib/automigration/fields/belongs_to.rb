module Automigration
  module Fields
    class BelongsTo < Sys::Base
      def to_db_columns
        [db_column_for_standart_types(:type => :integer, :name => "#{@name}_id")]
      end

      def extend_model!(model)
        super

        model.belongs_to @name, :class_name => @options[:class_name]

        if @options[:accessible]
          model.attr_accessible "#{@name}_id"
        end
      end

      def assert_options!
        raise "wrong name '#{@name}'" if @name =~ /_id$/
        @options = @options.reverse_merge(:allow_blank => false)

        if @options[:get_all]
          raise ":get_all should be Proc" unless @options[:get_all].is_a? Proc
          raise ":get_all wants arity: -1, 0, 1" unless [-1, 0, 1].include?(@options[:get_all].arity)
        end

        if @options[:to_title]
          raise ":to_title should be Proc" unless @options[:to_title].is_a? Proc
          raise ":to_title wants arity: 1, 2" unless [1, 2].include?(@options[:to_title].arity)
        end
      end

      def valid_options_keys
        super + [:class_name, :allow_blank, :get_all, :to_title]
      end

      def edit(template, object, object_name)
        edit_wrapper template, object, object_name do
          template.select(object_name, "#{@name}_id", get_collection(object), :object => object)
        end
      end

      def show(template, object, object_name)
        show_wrapper template, object, object_name do
          value_to_title(object.send(@name), object)
        end
      end

      private
      def value_to_title(value, object)
        if value
          if @options[:to_title]
            if @options[:to_title].arity == 1
              return @options[:to_title].call(value)
            else
              return @options[:to_title].call(value, object)
            end
          end

          %w(name title).each do |method|
            return value.send(method) if value.respond_to?(method)
          end

          "#{value.class.model_name.human} ##{value.id}"
        end
      end

      def get_collection(object)
        if @options[:get_all]
          if [0, -1].include? @options[:get_all].arity
            collection = @options[:get_all].call
          else
            collection = @options[:get_all].call object
          end
        else
          klass = (@options[:class_name] || @name.to_s.camelize).constantize
          collection = klass.all
        end

        out = []
        out << ["", ""] if @options[:allow_blank]
        out += collection.map{|val| [value_to_title(val, object), val.id]}
        out
      end
    end
  end
end
