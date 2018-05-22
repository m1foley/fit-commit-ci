require "test_helper"

class ActiveModelErrorsTest < ActiveSupport::TestCase
  class ClassWithValidations
    include ActiveModel::Model
    validates :bar, :baz, presence: true
    attr_accessor :bar, :baz
  end

  def test_error_messages_formatted
    instance = ClassWithValidations.new
    assert_not instance.valid?
    assert_equal "Bar can't be blank, Baz can't be blank",
      instance.error_messages_formatted
  end

  def test_add_errors_from
    instance1 = ClassWithValidations.new
    instance2 = ClassWithValidations.new
    assert_not instance1.valid?
    instance2.add_errors_from(instance1)
    assert_equal instance1.errors.full_messages, instance2.errors.full_messages
  end
end
