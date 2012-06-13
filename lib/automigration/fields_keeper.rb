module Automigration
  class FieldsKeeper
    attr_reader :fields
    attr_reader :migration_attrs

    def initialize(model)
      @model = model
      @fields = nil
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
      @fields.map do |field|
        Field.to_db_columns(field)
      end.flatten
    end
  end
end
