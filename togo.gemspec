require 'rake/gempackagetask'

Gem::Specification.new do |s|
  s.name = %q{togo}
  s.version = "0.4"
  s.date = %q{2010-08-10}
  s.authors = ["Matt King"]
  s.email = %q{matt@mattking.org}
  s.summary = %q{Automatic Content Admin Tool for Ruby ORMs}
  s.homepage = %q{http://github.com/mattking17/Togo/}
  s.description = %q{With a few lines of code in your Ruby ORMs, you get a highly configurable and extensive content administration tool.}
  s.platform = Gem::Platform::RUBY
  s.require_paths = ['lib','lib/togo/model','lib/togo/dispatch','lib/togo/admin']
  s.bindir = 'bin'
  s.executables = ['togo-admin']
  s.files = FileList[
                     'README',
                     'Changelog',
                     'LICENSE',
                     'lib/**/*',
                     'bin/*'
                    ]
  s.add_dependency('dm-core','= 0.10.2')
  s.add_dependency('erubis','> 0.0.0')
end
