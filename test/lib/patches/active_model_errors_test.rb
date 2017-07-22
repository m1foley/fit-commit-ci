require "test_helper"

class ActiveModelErrorsTest < ActiveSupport::TestCase
  def test_error_messages_formatted
    klass = Class.new do
      include ActiveModel::Model
      attr_accessor :bar, :baz
      validates :bar, :baz, presence: true
      def self.model_name
        ActiveModel::Name.new(self, nil, "TestClass")
      end
    end

    instance = klass.new
    assert !instance.valid?
    assert_equal "Bar can't be blank, Baz can't be blank",
      instance.error_messages_formatted
  end
end
