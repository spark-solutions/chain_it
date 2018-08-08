class ChainIt
  DEFAULT_SETTINGS = { auto_exception_handling: false }.freeze
  INVALID_RESULT_MSG = "ChainIt#chain block must return both #value and #failure? aware object.\n Check documentation: https://github.com/spark-solutions/chain_it#usage"
	
  def initialize(settings = {})
    @settings = DEFAULT_SETTINGS.merge(settings)
  end

  def chain
    if @skip_next
      @skip_next = false
      return self
    end

    return self if @skip
    @skip_next = false

    @result = yield result_value
    @skip = true if result_failure?
    self

  rescue StandardError => e
    raise e unless @settings[:auto_exception_handling]
    @result = e
    @skip = true
  end

  def skip_next
    return self if @skip
    @skip_next = yield result_value
    self
  end

  def on_error
    return self unless @skip
    yield result_value
    @skip = false
    self
  end

  def result
    @result
  end

  private

  def handle_wrong_result_api
    yield
  rescue NoMethodError
    raise StandardError.new INVALID_RESULT_MSG
  end

  def result_value
    handle_wrong_result_api { @result&.value }
  end

  def result_failure?
    handle_wrong_result_api { @result.failure? }
  end
end

require 'chain_it/version'
