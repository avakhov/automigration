module Automigration
  class DbColumn < Struct.new(:name, :type, :options)
    def initialize(name_, type_, options_)
      super
      options_.assert_valid_keys(:default, :null, :limit, :scale, :precision)
    end

    def self.from_activerecord_column(column)
      out = DbColumn.new(column.name.to_sym, column.type.to_sym, {
        :default => column.default,
        :null => column.null,
        :limit => column.limit,
        :scale => column.scale,
        :precision => column.precision
      })
    end

    def the_same?(other)
      (__to_array <=> other.send(:__to_array)) == 0
    end

    def to_options
      options.reject{|k, v| v.nil?}
    end

    private
    # compare only by 3 values
    def __to_array
      [name.to_s, type.to_s, options[:default].to_s]
    end
  end
end
