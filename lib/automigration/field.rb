module Automigration
  module Field
    KIND = %w[
      belongs_to
      boolean
      date
      datetime
      float
      integer
      string
      text
      time
    ]

    def self.to_db_columns(field) 
      type = field[:as]

      if type == :belongs_to
        name = "#{field[:name]}_id"
        column_type = :integer
      else
        name = field[:name]
        column_type = type
      end

      if type == :boolean
        default = !!field[:default]
      else
        default = field[:default]
      end
      
      Automigration::DbColumn.new(name, column_type, {
        :default => default,
        :null => field[:null], 
        :limit => field[:limit], 
        :scale => field[:scale], 
        :precision => field[:precision]
      })
    end

    def self.valid_options_keys(field)
      valid_keys = [
        :name, :as,                                  # system attributes
        :default, :null, :limit, :scale, :precision, # db columns keys
        :accessible                                  # mark attribute as accessible
      ]

      type = field[:as]

      if type == :belongs_to
        valid_keys += [:class_name, :inverse_of]
      end

      field.assert_valid_keys(*valid_keys)
    end

    def self.extend_model!(model, field)
      type = field[:as]
      name = field[:name]
      accessible = (field[:accessible] == nil) || field[:accessible]
      
      if type == :belongs_to
        model.belongs_to name, :class_name => field[:class_name], :inverse_of => field[:inverse_of]

        if accessible
          model.attr_accessible "#{name}_id"
        end
      end

      if accessible
        model.attr_accessible name
      end
    end
  end
end
