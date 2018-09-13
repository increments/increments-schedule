lib = File.expand_path('lib', __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'increments/schedule/version'

Gem::Specification.new do |spec|
  spec.name          = 'increments-schedule'
  spec.version       = Increments::Schedule::VERSION
  spec.authors       = ['Yuji Nakayama']
  spec.email         = ['nkymyj@gmail.com']

  spec.summary       = "Convenient library for checking Increments' company schedule"
  spec.description   = spec.summary
  spec.homepage      = 'https://github.com/increments/increments-schedule'
  spec.license       = 'MIT'

  spec.files = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.bindir        = 'exe'
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.add_runtime_dependency 'holiday_japan', '~> 1.1'

  spec.add_development_dependency 'bundler', '~> 1.3'
end
