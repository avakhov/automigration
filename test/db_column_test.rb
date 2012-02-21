require 'test_helper'

module Automigration
  class DbColumnTest < ActiveSupport::TestCase
    def test_the_same
      a = Fields::Sys::DbColumn.new('field', 'integer',
        :default => 3,
        :null => true,
        :limit => 3,
        :scale => 1,
        :precision => 2)

      b = Fields::Sys::DbColumn.new('field', 'integer',
        :default => 3,
        :null => true,
        :limit => 3,
        :scale => 1,
        :precision => 2)

      assert a.the_same?(b)
    end
  end
end
