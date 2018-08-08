require 'spec_helper'

RSpec.describe ChainIt do
  let(:result_object) { double('result object', failure?: false, value: true) }
  let(:service_object) { double('service object', call: result_object) }

  describe '#chain' do
    it 'always returns it\'s receiver' do
      expect(subject.chain { service_object.call }).to eq subject
    end

    context 'when the block responds with invalid object' do
      let(:result_object) { Struct.new('Result') }

      it 'responds with self explanatory error' do
        expect { subject.chain { service_object.call } }.
          to raise_error(StandardError, ChainIt::INVALID_RESULT_MSG)
      end
    end

    context 'when the code within the block raises error' do
      subject { described_class.new(opts) }
      before { allow(subject).to receive(:result_value).and_raise }

      context 'with :auto_exception_handling mode' do
        context 'enabled' do
	  let(:opts) { { auto_exception_handling: true } }

       	  it 'rescues the error' do
	    expect { subject.chain { service_object.call } }.not_to raise_error
	  end
        end

        context 'disabled' do
          let(:opts) { { auto_exception_handling: false } }

	  it 're-raises the error' do
 	    expect { subject.chain { service_object.call } }.to raise_error
          end
        end
      end
    end
  end

  describe '#skip_next' do
    context 'when passed block evaluates to true' do
      it 'skips the next #chain execution' do
	expect(service_object).not_to receive(:call)

	subject.skip_next { true }.
	        chain { service_object.call }
      end
    end

    context 'when passed block evaluates to false' do
      it 'does not skip the next #chain execution' do
       	expect(service_object).to receive(:call)

        subject.skip_next { false }.
                chain { service_object.call }
      end
    end
  end

  xdescribe '#on_error' do; end

  describe '#result' do
    let(:result_object2) { double('result object 2', failure?: false, value: false) }
    let(:service_object2) { double('service object 2', call: result_object2) }

    context 'when all the chanis are successful' do
      it 'returns the last chain\'s response' do
        expect(subject.chain { service_object.call }.
                       chain { service_object2.call }.
                       result).to eq result_object2
      end
    end

    context 'when some chain is failed' do
      let(:result_object) { double('result object', failure?: true, value: false) }

      it 'returns the last successful chain\'s response' do
        expect(subject.chain { service_object.call }.
                       chain { service_object2.call }.
                       result).to eq result_object
      end
    end
  end

  context 'yield control' do
    let(:to_proc) do
      proc do |block|
        block.define_singleton_method(:to_proc) do
          # Rspec-Expectations hack to inject the passed block's value to the inside of the method
          # https://github.com/rspec/rspec-expectations/blob/v3.1.0/lib/rspec/matchers/built_in/yield.rb#L39
          @used = true
          probe = self
          callback = @callback
          proc do |*args|
            probe.num_yields += 1
            probe.yielded_args << args
            callback.call(*args)
            RSpec::Mocks::Double.new(failure?: false, value: true)
          end
        end
      end
    end

    specify 'in the first #chain call it yields with nil' do
      expect do |block|
        to_proc.call(block)

        subject.chain(&block)
      end.to yield_with_args(nil)
    end

    specify 'in the subsequent #chain call it yields with the previous #chain call result' do
      expect do |block|
        to_proc.call(block)

        subject.chain(&block).chain(&block)
      end.to yield_successive_args(nil, true)
    end
  end

  it 'has a version number' do
    expect(ChainIt::VERSION).to eq '1.1.0'
  end
end
