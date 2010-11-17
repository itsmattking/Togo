require 'init'

Togo::Admin.configure({
                        :site_title => "Food Carts API",
                        :auth_model => User,
                        :sessions => true
                      })
