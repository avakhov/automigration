module ActiveRecord
  class Base
    class_attribute :__fields_keeper
    self.__fields_keeper = nil

    def self.fields_keeper
      self.__fields_keeper ||= ::Automigration::Fields::Sys::Keeper.new(self)
    end

    class << self
      delegate :has_fields, :add_field, :migration_attr, :to => :fields_keeper
      delegate :get_field, :get_field_safe, :get_fields, :to => :fields_keeper
    end
  end
end
