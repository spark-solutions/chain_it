
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'chain_it/version'

Gem::Specification.new do |spec|
  spec.name          = 'chainit'
  spec.version       = ChainIt::VERSION
  spec.authors       = %w[btolarz nnande]
  spec.email         = ['btolarz@gmail.com']

  spec.summary       = 'A tool for executing successive tasks in a railway-oriented manner'
  spec.description   = "It can successfully replace conceptually similar libraries like Dry-transaction. It's all because of the simplicity its code offers."
  spec.homepage      = 'https://github.com/spark-solutions/chain_it'
  spec.license       = 'MIT'

  spec.files = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end
  spec.bindir        = 'exe'
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.add_development_dependency 'bundler', '~> 1.14'
  spec.add_development_dependency 'rake', '~> 10.0'
  spec.add_development_dependency 'rspec', '~> 3.0'
end
