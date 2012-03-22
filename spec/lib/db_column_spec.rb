require 'spec_helper'

describe 'db column' do
  it "the same" do
    a = Automigration::DbColumn.new('field', 'integer',
      :default => 3,
      :null => true,
      :limit => 3,
      :scale => 1,
      :precision => 2)

    b = Automigration::DbColumn.new('field', 'integer',
      :default => 3,
      :null => true,
      :limit => 3,
      :scale => 1,
      :precision => 2)

    a.the_same?(b).should be_true
  end
end
