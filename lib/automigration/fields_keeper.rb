module Automigration
  class FieldsKeeper
    attr_reader :fields
    attr_reader :migration_attrs

    def initialize(model)
      @model = model
      @fields = nil
      @devise_fields = []
      @migration_attrs = []
      @timestamps_added = false

      @fields_lookup = {}
    end

    def has_fields(options = {}, &block)
      options.assert_valid_keys(:timestamps)
      options.reverse_merge!(:timestamps => true)

      dsl = Automigration::Dsl.new
      block.arity == 1 ?  block.call(dsl) : dsl.instance_exec(&block)

      dsl.fields.each do |field|
        Field.extend_model!(@model, field)
      end

      @fields ||= []
      @fields += dsl.fields
      @devise_fields = dsl.devise_fields

      if !@timestamps_added && options[:timestamps]
        @timestamps_added = true
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

    def field_names
      @field_names ||= fields.map{|f| f[:name]}
    end

    def field_db_columns
      out = []

      out += @fields.map do |field|
        Field.to_db_columns(field)
      end.flatten

      if defined?(Devise::Schema) && !@devise_fields.empty?
        devise_schema = Class.new do
          include Devise::Schema

          define_method :apply_devise_schema do |*args|
            opts = args.extract_options!
            raise "wrong arguments" unless args.size == 2
            name = args[0]
            as = args[1].to_s.underscore.to_sym
            as = :datetime if as == :date_time
            out << Automigration::DbColumn.new(name, as, opts)
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
