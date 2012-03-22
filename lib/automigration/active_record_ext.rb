module ActiveRecord
  class Base
    class_attribute :__fields_keeper
    self.__fields_keeper = nil

    def self.__fields_keeper_instance
      self.__fields_keeper ||= ::Automigration::FieldsKeeper.new(self)
    end

    class << self
      delegate :has_fields, :add_field, :migration_attr, :to => :__fields_keeper_instance
      delegate :auto_migrable?, :migration_attrs, :to => :__fields_keeper_instance
      delegate :field_db_columns, :to => :__fields_keeper_instance
      delegate :fields, :field_names, :to => :__fields_keeper_instance
    end
  end
end
