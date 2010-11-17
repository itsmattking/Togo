require 'dispatch'
require 'togo/admin/admin'

Togo::Admin.configure({
  :view_path => File.join($:.find{|p| p =~ /lib\/togo\/admin/},'views'),
  :public_path => File.join($:.find{|p| p =~ /lib\/togo\/admin/},'public'),
  :site_title => "Togo Admin"
})
