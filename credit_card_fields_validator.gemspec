# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'credit_card_fields_validator/version'

Gem::Specification.new do |spec|
  spec.name          = "validate_credit_card_fields"
  spec.version       = CreditCardFieldsValidator::VERSION
  spec.authors       = ["Piotr Kruczek", "Jacek Zachariasz", "Jan Grodowski", "Patryk Pastewski"]
  spec.email         = ["daftcode@daftcode.pl"]
  spec.summary       = %q{Credit card validation with all dependant fields}
  spec.description   = %q{Simple gem helpful in validating standard credit card forms}
  spec.homepage      = ""
  spec.license       = "MIT"

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_dependency "activemodel"

  spec.add_development_dependency "bundler", "~> 1.5"
  spec.add_development_dependency "rake"
  spec.add_development_dependency "rspec"
  spec.add_development_dependency "byebug"
end
