# Chainer
[![CircleCI](https://circleci.com/gh/spark-solutions/chainer/tree/master.svg?style=svg&circle-token=3bb16aef0dbcbe7fd18500376a110bd6cedf668a)](https://circleci.com/gh/spark-solutions/chainer/tree/master)

## Description
This provides the tool which is implementation of railway-oriented programming concept itself
(Read more on this <a href="https://fsharpforfunandprofit.com/rop">here</a>).

Ideally suited for executing task sequences that should be immediately interrupted when any subsequen task fails.

## Usage
Everything comes down to chaining subsequent `#chain` method calls to a `Chainer` object instance.

The gem supports design-by-contract programming concept - assuming every block related to `#chain` have to return both `#value` and `#failure?` aware object.We reccomend using Struct for that purpouse.

```ruby
Result = Struct.new(:success, :value) do
  def failure?
    !success
  end
end

```
### Examples

```ruby
# Basic flow explanation
success = ->(value) { Result.new(true, value) }

Chainer.new.
        chain { success.call 2 }.               #=> The subsequent chain will be triggered
        chain { |num| success.call(num * 2) }.  #=> We can pass the previous block evaluation as the block argument
        chain { |num| success.call(num * 2) }.
        result.
        value                                   #=> 8
  
# Working with #skip_next
Chainer.new.
        chain { success.call 2 }.               
        skip_next { |num| num == 2 }.           #=> The next chain will be skipped conditionally since block returns true
        chain { success.call 8 }.              
        chain { |num| success.call(num * 2) }.  #=> The block argument is the last executed #chain value
        result.
        value                                   #=> 4

# Dealing with a failure
failure = ->(value) { Result.new(false, value) }

Chainer.new.
        chain { success.call 2 }.
        chain { failure.call 0 }.               #=> All later #chain calls will be skipped
        chain { success.call 4 }.
        result.
        value                                   #=> 0 
```
## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/spark-solutions/chainer.

## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).
