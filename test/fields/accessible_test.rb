require 'test_helper'

module Automigration
  module Fields
    class AccessbileTest < ActiveSupport::TestCase
      test "mass assignment deny" do
        obj = AccessibleModel.create(:first => 123, :second => 345)
        assert_equal 123, obj.first
        assert_equal 0, obj.second
      end
    end
  end
end
