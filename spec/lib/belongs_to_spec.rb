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

  it "raise if wrong name" do
    lambda {
      Automigration::Fields::Sys::Base.from_meta(
        :as => :belongs_to,
        :name => "simple_id"
      )
    }.should raise_error(RuntimeError)
  end

  it "parent and children" do
    child = BelongsToModel.find(BelongsToModel.create(:parent => @obj).id)
    @obj.should == child.parent
    @obj.id.should == child.parent_id
  end
end
