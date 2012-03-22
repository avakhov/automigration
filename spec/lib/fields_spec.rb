require 'spec_helper'

describe 'fields' do
  it 'kind_of_field' do
    Automigration::Fields::Boolean.kind.should == :boolean
  end

  it 'automigrable_model' do
    Simple.fields_keeper.auto_migrable?.should be_true
    NotAutomigrable.fields_keeper.auto_migrable?.should be_false
  end

  it 'migrations_attrs' do
    AutoMigration1.fields_keeper.migration_attrs.should == []

    expected = ['some_attr1', 'some_attr2' , 'some_attr3']
    AutoMigration2.fields_keeper.migration_attrs.should == expected
  end

  it 'boolean_column_false_by_default' do
    AutoMigration1.new.boolean_field.should be_false
  end

  it 'from_meta' do
    Automigration::Fields::Sys::Base.from_meta(:as => :boolean, :name => 'some').class.should == Automigration::Fields::Boolean
  end

  it 'attributes_accessible' do
    obj = AutoMigration1.create(:integer_field => 123)
    obj.integer_field.should == 123
  end
end
