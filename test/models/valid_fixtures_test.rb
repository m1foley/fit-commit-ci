require "test_helper"

class ValidFixturesTest < ActiveSupport::TestCase
  def format_error(instance)
    "#{instance.error_messages_formatted} #{instance.inspect}"
  end

  def test_all_fixtures_are_valid
    fixture_files = Dir["test/fixtures/*.yml"]
    assert fixture_files.present?
    fixture_files.each do |fixture_file|
      klass = File.basename(fixture_file, ".yml").classify.constantize
      klass.all.each { |instance| assert_valid(instance) }
    end
  end

  def assert_valid(instance)
    assert instance.valid?, format_error(instance)
  rescue => e
    raise e, "#{e} #{instance.inspect}"
  end
end
