class RakeLogger
  def self.logger
    @logger ||= Logger.new($stdout)
  end
end
