require 'rake/gempackagetask'

Gem::Specification.new do |s|
  s.name = %q{togo}
  s.version = "0.7.0"
  s.date = %q{2011-06-30}
  s.authors = ["Matt King"]
  s.email = %q{matt@mking.me}
  s.summary = %q{CMS Framework for Ruby ORMs}
  s.homepage = %q{http://github.com/mattking17/Togo/}
  s.description = %q{With a few lines of code in your Ruby ORMs, you get a highly configurable and extensive content management tool (CMS).}
  s.platform = Gem::Platform::RUBY
  s.require_paths = ['lib','lib/togo/model','lib/togo/dispatch','lib/togo/admin']
  s.bindir = 'bin'
  s.executables = ['togo-admin']
  s.files = FileList[
                     'README.md',
                     'Changelog',
                     'LICENSE',
                     'lib/**/*',
                     'bin/*'
                    ]
  s.add_dependency('erubis','> 0.0.0')
end
