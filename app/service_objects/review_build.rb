class ReviewBuild
  def initialize(build)
    self.build = build
  end

  def call
    Rails.logger.info("Reviewing build: #{build.id}")
    [1, 2]
  end

  private

  attr_accessor :build
end
