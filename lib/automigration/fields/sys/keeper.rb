module Automigration
  module Fields
    module Sys
      class Keeper
        attr_reader :fields
        attr_reader :migration_attrs

        def initialize(model)
          @model = model
          @fields = nil
          @devise_fields = []
          @migration_attrs = []

          @fields_lookup = {}
        end

        def has_fields(options = {}, &block)
          options.assert_valid_keys(:timestamps)
          options.reverse_merge!(:timestamps => true)

          slice_creater = SliceCreater.new
          yield slice_creater

          slice_creater.fields.each do |field|
            Fields::Sys::Base.from_meta(field).extend_model!(@model)
          end

          @fields ||= []
          @fields += slice_creater.fields
          @devise_fields = slice_creater.devise_fields

          if options[:timestamps]
            @fields << {:as => :datetime, :name => :created_at, :accessible => false}
            @fields << {:as => :datetime, :name => :updated_at, :accessible => false}
          end
        end

        def add_field(type, name, options = {})
          has_fields(:timestamps => false) do |f|
            f.send type, name, options
          end
        end

        def migration_attr(*args)
          @migration_attrs += args.flatten.map(&:to_s)
        end

        def auto_migrable?
          @fields.present?
        end

        def get_field(field_name)
          @fields_lookup[field_name] ||= begin
            meta = @fields.detect{|meta| meta[:name] == field_name}
            raise "wrong field_name: #{field_name}" unless meta
            Fields::Sys::Base.from_meta(meta)
          end
        end

        def get_field_safe(field_name)
          get_field(field_name)
        rescue RuntimeError
        end

        def get_fields
          @get_fields ||= @fields.map do |meta|
            get_field(meta[:name])
          end
        end

        def db_columns_for_field(field_name)
          meta = @fields.detect{|meta| meta[:name] == field_name}
          if meta
            Fields::Sys::Base.from_meta(meta).to_db_columns
          else
            []
          end
        end

        def db_columns
          out = []

          out += @fields.map do |meta|
            Fields::Sys::Base.from_meta(meta).to_db_columns
          end.flatten

          if defined?(Devise::Schema)
            devise_schema = Class.new do
              include Devise::Schema

              define_method :apply_devise_schema do |*args|
                opts = args.extract_options!
                raise "wrong arguments" unless args.size == 2
                name = args[0]
                as = Utils.to_string(args[1]).to_sym
                as = :datetime if as == :date_time
                out << DbColumn.new(name, as, opts)
              end
            end.new

            @devise_fields.each do |meta|
              devise_schema.send(meta[:as].to_s.sub(/^devise_/, ''), *meta[:args])
            end
          end

          out
        end
      end
    end
  end
end
