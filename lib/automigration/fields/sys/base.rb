module Automigration
  module Fields
    module Sys
      class Base
        def self.all
          [
            Fields::BelongsTo,
            Fields::Boolean,
            Fields::Date,
            Fields::Datetime,
            Fields::Float,
            Fields::Integer,
            Fields::Password,
            Fields::String,
            Fields::Text,
            Fields::Time
          ]
        end

        attr_reader :options, :name

        def initialize(options)
          options.assert_valid_keys(valid_options_keys)

          @name = options[:name]
          @options = options.except(:name, :as).reverse_merge(:accessible => true)

          assert_options!
        end

        # overload these methods if needed [begin]
        def to_db_columns
          []
        end

        def valid_options_keys
          [
            :name, :as,                                  # system attributes
            :default, :null, :limit, :scale, :precision, # db columns keys
            :accessible,                                 # mark attribute as accessible
            :ru, :en, :de                                # languages
          ]
        end

        def assert_options!
        end

        def extend_model!(model)
          if @options[:accessible]
            model.attr_accessible @name
          end
        end

        def edit(template, object, object_name)
          edit_wrapper template, object, object_name do
            template.text_field(object_name, name, :object => object)
          end
        end

        def show(template, object, object_name)
          show_wrapper template, object, object_name do
            object.send(@name)
          end
        end
        # overload these methods if needed [end]

        def self.kind
          if self == Base
            raise "not call this method for Fields::Sys::Base class"
          end
          self.to_s.underscore.sub("automigration/fields/", '').to_sym
        end

        def self.from_meta(meta)
          all.each do |field_class|
            if field_class.kind == meta[:as]
              return field_class.new(meta)
            end
          end
          raise "wrong meta: #{meta.inspect}"
        end

        protected
        def db_column_for_standart_types(options = {})
          options.assert_valid_keys(:default, :null, :limit, :scale, :precision, :type, :name)

          if options[:type]
            type = options[:type]
          else
            type = self.class.kind
          end

          if options[:name]
            column_name = options[:name]
          else
            column_name = @name
          end

          DbColumn.new(column_name, type, options.except(:type, :name).reverse_merge({
            :default => @options[:default], 
            :null => @options[:null], 
            :limit => @options[:limit], 
            :scale => @options[:scale], 
            :precision => @options[:precision]
          }))
        end

        def show_wrapper(template, object, object_name, &block)
          self_name = @name

          template.content_tag(:div, :class => 'field') do
            template.safe_join [
              template.content_tag(:b, label_title(object) + ':'),
              '<br>'.html_safe,
              yield
            ]
          end
        end

        def edit_wrapper(template, object, object_name, &block)
          self_name = @name

          template.content_tag(:div, :class => 'field') do
            template.safe_join [
              template.label(object_name, self_name, label_title(object)),
              '<br>'.html_safe,
              yield
            ]
          end
        end

        private
        def label_title(object)
          if @options.key?(I18n.locale)
            @options[I18n.locale]
          else
            object.class.human_attribute_name(@name)
          end
        end
      end
    end
  end
end
