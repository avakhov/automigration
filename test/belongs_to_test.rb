require 'test_helper'

module Automigration
  class BelongsTest < ActiveSupport::TestCase
    include ActionDispatch::Assertions::SelectorAssertions

    setup do
      @simple = Simple.create
      @obj = BelongsToModel.create
    end

    teardown do 
      Simple.destroy_all
    end

    test "properties" do
      assert_nil @obj.simple
      assert_nil @obj.simple_id
    end

    test "mass assignment by object" do
      @obj.update_attributes(:simple => @simple)
      assert_equal @simple.id, @obj.simple_id 
    end

    test "mass assignment by id" do
      @obj.update_attributes(:simple_id => @simple.id)
      assert_equal @simple.id, @obj.simple_id 
    end

    test "use different class name" do
      @obj.update_attributes(:some => @simple)
      assert_equal @simple, @obj.some
    end

    test "raise if wrong name" do
      assert_raise RuntimeError do
        Fields::Sys::Base.from_meta(
          :as => :belongs_to,
          :name => "simple_id"
        )
      end
    end

    test "parent and children" do
      child = BelongsToModel.find(BelongsToModel.create(:parent => @obj).id)
      assert_equal @obj, child.parent
      assert_equal @obj.id, child.parent_id
    end
  end
end
