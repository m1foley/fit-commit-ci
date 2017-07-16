require "test_helper"

class ActiveModelErrorsTest < ActiveSupport::TestCase
  test "error_messages_formatted should join error messages" do
    class Foo
      include ActiveModel::Model
      attr_accessor :bar, :baz
      validates :bar, :baz, presence: true
    end

    instance = Foo.new
    assert !instance.valid?
    assert_equal "Bar can't be blank, Baz can't be blank",
      instance.error_messages_formatted
  end
end
