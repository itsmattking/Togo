class User
  include DataMapper::Resource

  attr_accessor :authenticated

  property :id, Serial
  property :username, String
  property :password, String

  def authenticated?
    authenticated || false
  end

  def self.authenticate(u, p)
    u = first(:username => u, :password => p)
    u.authenticated = true if u
    u
  end

end
