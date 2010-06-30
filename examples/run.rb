# put all our paths first in case gem is installed
%w(lib lib/togo/model lib/togo/dispatch lib/togo/admin bin).each do |w|
  $:.unshift(File.join(File.dirname(__FILE__),'..',w))
end
require '../lib/togo'
load '../bin/togo-admin'
