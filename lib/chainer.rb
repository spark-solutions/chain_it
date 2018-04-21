require 'chainer/version'

class Chainer
  def chain
    return self if @skip
    @result = yield @result&.value
    @skip = true if @result.failure?
    self
  end

  def result
    @result
  end
end
