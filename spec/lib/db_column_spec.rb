require 'spec_helper'

describe 'db column' do
  it "the same" do
    a = Automigration::Fields::Sys::DbColumn.new('field', 'integer',
      :default => 3,
      :null => true,
      :limit => 3,
      :scale => 1,
      :precision => 2)

    b = Automigration::Fields::Sys::DbColumn.new('field', 'integer',
      :default => 3,
      :null => true,
      :limit => 3,
      :scale => 1,
      :precision => 2)

    assert a.the_same?(b)
  end
end
