$:.push File.expand_path("../lib", __FILE__)
require 'qipowl/version'

Gem::Specification.new do |s|
  s.name = 'qipowl'
  s.version = Qipowl::VERSION
  s.platform = Gem::Platform::RUBY
  s.license = 'MIT'
  s.date = '2013-09-08'
  s.authors = ['Alexei Matyushkin']
  s.email = 'am@mudasobwa.ru'
  s.homepage = 'http://github.com/mudasobwa/qipowl'
  s.summary = %Q{Parser framework totally based on DSL}
  s.description = %Q{Multipurpose DSL-based pure text parser.}
  s.extra_rdoc_files = [
    'LICENSE',
    'README.md',
  ]

  s.required_rubygems_version = Gem::Requirement.new('>= 1.3.7')
  s.rubygems_version = '1.3.7'
  s.specification_version = 3

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.bindir        = 'bin'
  s.executables   = ['bowler']
  s.require_paths = ['lib']

  s.add_development_dependency 'rspec'
  s.add_development_dependency 'fuubar'
  s.add_development_dependency 'yard'
  s.add_development_dependency 'cucumber'
  s.add_development_dependency 'yard-cucumber'

  s.add_dependency 'psych'
  s.add_dependency 'unicode'
  s.add_dependency 'crochets'
end

