require 'spec_helper'

describe 'accessible' do
  it "mass assignment deny" do
    lambda {
      AccessibleModel.create(:first => 123)
    }.should_not raise_error

    lambda {
      AccessibleModel.create(:second => 345)
    }.should raise_error
  end
end
