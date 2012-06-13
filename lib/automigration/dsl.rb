module Automigration
  class Dsl
    attr_reader :fields

    def initialize
      @fields = []
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
  end
end
