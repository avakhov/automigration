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
    @obj.simple.should be_nil
    @obj.simple_id.should be_nil
  end

  it "mass assignment by object" do
    @obj.update_attributes(:simple => @simple)
    @simple.id.should == @obj.simple_id 
  end

  it "mass assignment by id" do
    @obj.update_attributes(:simple_id => @simple.id)
    @simple.id.should == @obj.simple_id 
  end

  it "use different class name" do
    @obj.update_attributes(:some => @simple)
    @simple.should == @obj.some
  end

  it "parent and children" do
    child = BelongsToModel.find(BelongsToModel.create(:parent => @obj).id)
    @obj.should == child.parent
    @obj.id.should == child.parent_id
  end
end
