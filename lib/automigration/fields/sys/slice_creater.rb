module Automigration
  module Fields
    module Sys
      class SliceCreater
        attr_reader :fields
        attr_reader :devise_fields

        def initialize
          @fields = []
          @devise_fields = []
        end

        Fields::Sys::Base.all.each do |field_class|
          define_method field_class.kind do |*args|
            options = args.extract_options!
            raise "wrong amount of args" unless args.size == 1
            name = args[0]
            @fields << {:name => name, :as => field_class.kind}.merge(options)
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
  end
end
