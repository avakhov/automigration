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

    test "show - not nil" do
      @obj.update_attributes(:simple => @simple)
      field = @obj.class.get_field(:simple)

      html = field.show(ActionController::Base.helpers, @obj, 'belongs_to_model')

      assert_select HTML::Document.new(html).root, '.field', Regexp.new("Simple ##{@simple.id}")
    end

    test "show - nil" do
      field = @obj.class.get_field(:simple)

      html = field.show(ActionController::Base.helpers, @obj, 'belongs_to_model')

      assert_select HTML::Document.new(html).root, '.field', "Simple:"
    end

    test "show - with name" do
      with_name = SimpleWithName.create!(:name => 'abc')
      @obj.update_attributes(:simple_with_name => with_name)
      field = @obj.class.get_field(:simple_with_name)

      html = field.show(ActionController::Base.helpers, @obj, 'belongs_to_model')

      assert_select HTML::Document.new(html).root, '.field', /abc/
    end

    test "edit - not nil" do
      @obj.update_attributes(:simple => @simple)
      field = @obj.class.get_field(:simple)

      html = field.edit(ActionController::Base.helpers, @obj, 'belongs_to_model')

      assert_select HTML::Document.new(html).root, '.field' do
        assert_select 'select' do
          assert_select 'option[value=?]', @simple.id, "Simple ##{@simple.id}"
        end
      end
    end

    test "edit - allow blank" do
      @obj.update_attributes(:simple_allow_blank => @simple)
      field = @obj.class.get_field(:simple_allow_blank)

      html = field.edit(ActionController::Base.helpers, @obj, 'belongs_to_model')

      assert_select HTML::Document.new(html).root, '.field' do
        assert_select 'select[name=?]', 'belongs_to_model[simple_allow_blank_id]' do
          assert_select 'option[value=?]', '', ''
          assert_select 'option[value=?]', @simple.id, "Simple ##{@simple.id}"
        end
      end
    end

    test "get_all proc: arity 0" do
      simple2 = Simple.create
      assert_equal 2, Simple.count
      field = @obj.class.get_field(:simple_with_get_all0)

      html = field.edit(ActionController::Base.helpers, @obj, 'belongs_to_model')

      assert_select HTML::Document.new(html).root, '.field' do
        assert_select 'select[name=?]', 'belongs_to_model[simple_with_get_all0_id]' do
          assert_select 'option', 1
          assert_select 'option[value=?]', simple2.id, "Simple ##{simple2.id}"
        end
      end
    end

    test "get_all proc: arity 1" do
      simple2 = Simple.create!
      assert_equal 2, Simple.count
      field = @obj.class.get_field(:simple_with_get_all1)
      obj2 = BelongsToModel.create!(:name => 'all')

      html = field.edit(ActionController::Base.helpers, @obj, 'belongs_to_model')
      assert_select HTML::Document.new(html).root, '.field' do
        assert_select 'select[name=?]', 'belongs_to_model[simple_with_get_all1_id]' do
          assert_select 'option', 1
          assert_select 'option[value=?]', @simple.id, "Simple ##{@simple.id}"
        end
      end

      html = field.edit(ActionController::Base.helpers, obj2, 'belongs_to_model')
      assert_select HTML::Document.new(html).root, '.field' do
        assert_select 'select[name=?]', 'belongs_to_model[simple_with_get_all1_id]' do
          assert_select 'option', 2
          assert_select 'option[value=?]', @simple.id, "Simple ##{@simple.id}"
          assert_select 'option[value=?]', simple2.id, "Simple ##{simple2.id}"
        end
      end
    end

    test "to title proc - arity 1" do
      field = @obj.class.get_field(:simple_with_to_title1)

      assert_equal %(<div class="field"><b>Simple with to title1:</b><br></div>),
        field.show(ActionController::Base.helpers, @obj, 'belongs_to_model')

      @obj.update_attributes(:simple_with_to_title1 => @simple)

      assert_equal %(<div class="field"><b>Simple with to title1:</b><br>#{@simple.id}</div>),
        field.show(ActionController::Base.helpers, @obj, 'belongs_to_model')
    end

    test "to title proc - arity 2" do
      field = @obj.class.get_field(:simple_with_to_title2)

      assert_equal %(<div class="field"><b>Simple with to title2:</b><br></div>),
        field.show(ActionController::Base.helpers, @obj, 'belongs_to_model')

      @obj.update_attributes(:simple_with_to_title2 => @simple)

      assert_equal %(<div class="field"><b>Simple with to title2:</b><br>#{@simple.id + @obj.id}</div>),
        field.show(ActionController::Base.helpers, @obj, 'belongs_to_model')
    end
  end
end
