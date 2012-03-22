require 'spec_helper'

describe 'fields' do
  it 'automigrable_model' do
    Simple.auto_migrable?.should be_true
    NotAutomigrable.auto_migrable?.should be_false
  end

  it 'migrations_attrs' do
    AutoMigration1.migration_attrs.should == []
    AutoMigration2.migration_attrs.should == %w[some_attr1 some_attr2 some_attr3]
  end

  it 'boolean_column_false_by_default' do
    AutoMigration1.new.boolean_field.should be_false
  end

  it 'attributes_accessible' do
    obj = AutoMigration1.create(:integer_field => 123)
    obj.integer_field.should == 123
  end
end
