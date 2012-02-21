require 'test_helper'

module Automigration
  module Fields
    class BooleanFieldTest < ActiveSupport::TestCase
      include ActionDispatch::Assertions::SelectorAssertions

      setup do
        @obj = BooleanModel.create
        @field = @obj.class.get_field(:value)
      end

      test "edit" do
        html = @field.edit(ActionController::Base.helpers, @obj, 'boolean_model')

        assert_select HTML::Document.new(html).root, '.field' do
          assert_select 'label', 'Value'
          assert_select 'br'
          assert_select 'input[type=hidden][value=?]', '0'
          assert_select 'input[type=checkbox]'
        end
      end

      test "show - false" do
        html = @field.show(ActionController::Base.helpers, @obj, 'boolean_model')

        assert_select HTML::Document.new(html).root, '.field', /no/ do
          assert_select 'b', 'Value:'
          assert_select 'br'
        end
      end

      test "show - true" do
        @obj.value = true

        html = @field.show(ActionController::Base.helpers, @obj, 'boolean_model')

        assert_select HTML::Document.new(html).root, '.field', /yes/ do
          assert_select 'b', 'Value:'
          assert_select 'br'
        end
      end
    end
  end
end
