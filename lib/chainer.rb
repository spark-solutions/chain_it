class Chainer
  def chain
    if @skip_next
      @skip_next = false
      return self
    end

    return self if @skip
    @skip_next = false
    @result = yield @result&.value
    @skip = true if @result.failure?
    self
  end

  def skip_next
    return self if @skip
    @skip_next = yield @result&.value
    self
  end

  def on_error
    return self unless @skip
    yield @result&.value
    @skip = false
    self
  end

  def result
    @result
  end
end

require 'chainer/version'
