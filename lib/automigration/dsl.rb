module Automigration
  class Dsl
    attr_reader :fields
    attr_reader :devise_fields

    def initialize
      @fields = []
      @devise_fields = []
    end

    Field::KIND.each do |field|
      define_method field do |*args|
        options = args.extract_options!
        raise "wrong amount of args" unless args.size == 1
        name = args[0]
        @fields << {:name => name, :as => field.to_sym}.merge(options)
        Field.valid_options_keys(@fields.last)
      end
    end

    def method_missing(meth, *args, &block)
      if meth.to_s =~ /^devise_(.*)/
        @devise_fields << {:as => meth, :args => args}
      else
        super
      end
    end
  end
end
