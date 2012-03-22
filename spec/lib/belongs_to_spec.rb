require 'spec_helper'

describe "belongs to" do
  before do
    @simple = Simple.create
    @obj = BelongsToModel.create
  end

  after do 
    Simple.destroy_all
  end

  it "properties" do
    assert_nil @obj.simple
    assert_nil @obj.simple_id
  end

  it "mass assignment by object" do
    @obj.update_attributes(:simple => @simple)
    assert_equal @simple.id, @obj.simple_id 
  end

  it "mass assignment by id" do
    @obj.update_attributes(:simple_id => @simple.id)
    assert_equal @simple.id, @obj.simple_id 
  end

  it "use different class name" do
    @obj.update_attributes(:some => @simple)
    assert_equal @simple, @obj.some
  end

  it "raise if wrong name" do
    assert_raise RuntimeError do
      Automigration::Fields::Sys::Base.from_meta(
        :as => :belongs_to,
        :name => "simple_id"
      )
    end
  end

  it "parent and children" do
    child = BelongsToModel.find(BelongsToModel.create(:parent => @obj).id)
    assert_equal @obj, child.parent
    assert_equal @obj.id, child.parent_id
  end
end
