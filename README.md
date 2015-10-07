# Introducing Togo

Togo is a CMS framework. The goal of Togo is to be a modular system that can be used with any Ruby ORM framework, giving you a complete CMS right out of the box.
It is built to be as independent as possible from other web frameworks such as Rails or Sinatra, and only needs Rack and your choice of HTTP server to run (such as thin, mongrel or webrick).
Togo is focused only on making a quick and easy way to manage content, and is less about integrating into your existing web application.

## Installation

    gem install togo

## Example Application

An example application is available: [http://github.com/mattking17/Togo-Example-App](http://github.com/mattking17/Togo-Example-App)

## Tutorial

Togo works by a simply including a line in your model definition (currently, Togo only works for DataMapper). By including Togo in your model,
it will be automatically integrated into the Togo admin application, giving you all the CRUD actions as well as listing and search. It even
works with associations.

### Setting up a simple application

We'll use a combination of Sinatra, DataMapper and Sqlite for our tutorial. You actually don't need Sinatra to run the Togo admin application, however this
gives a good idea of how Togo can be used in conjunction with an existing project.

You'll need the following gems installed:

    dm-core dm-serializer sinatra dm-sqlite3-adapter

Next, make a directory for your project like so:


    togo-example/
    |
    -- models/
    |
    -- views/
    |
    -- init.rb
    |
    -- app.rb
    |
    -- example.db


### Set up your models

Inside the models directory, create a blog_entry.rb and comment.rb file, and drop in the following:


    #blog_entry.rb:

    class BlogEntry

      include DataMapper::Resource
      include Togo::DataMapper::Model

      property :id, Serial
      property :title, String
      property :body, Text
      property :date, DateTime

      has n, :comments

    end

    #comment.rb:

    class Comment
      include DataMapper::Resource
      include Togo::DataMapper::Model

      property :id, Serial
      property :name, String
      property :email, String
      property :body, Text
      property :date, DateTime
      property :blog_entry_id, Integer

      belongs_to :blog_entry
    end


### Create an init file

Togo doesn't set up your database connection or initialize anything needed by your models for you, so you'll have to tell
it what to do. There are a couple ways of doing it: put the code in a file of your choice and tell Togo to include
it at runtime, or place the code in a file called togo-admin-config.rb in the same directory that you will run Togo from.

In this example, we'll put our initialization in the init.rb file and tell Togo to include it at boot time.


    #init.rb:

    SITE_ROOT = File.dirname(File.expand_path(__FILE__))
    %w(dm-core dm-migrations togo).each{|l| require l}
    Dir.glob(File.join(SITE_ROOT,'models','*.rb')).each{|f| require f}
    DataMapper::Logger.new(STDOUT, :debug)
    DataMapper.setup(:default, "sqlite3://#{Dir.pwd}/example.db")
    DataMapper.auto_upgrade!


### You're ready to start using Togo

At this point you can fire up the Togo admin application. Remember we have to include our init.rb file:

    togo-admin -r init.rb

Open up http://0.0.0.0:8080 in your browser and have a blast! Have a look at our CMS User's Guide for a walkthrough of base CMS functionality (Coming Soon).

## Customizing Togo

Togo is set up to work with sensible defaults out of the box, but you can customize what fields are used, what order they appear, and even 
use your own templates to show fields when editing or creating content.

### Telling Togo which fields to use

By default Togo will look at your model and include all available fields in the admin, but you can also tell it specifically which fields
to use for both the list view and form view.

#### Changing the list view

If you only want the title and date field to appear in the list view of blog entries, just add in to your model definition:


    class BlogEntry

      include DataMapper::Resource
      include Togo::DataMapper::Model
      ... snipped ...

      list_properties :title, :date

    end


Togo will display the fields in the order given. So if you wanted date first some reason, you could just do

    list_properties :date, :title

And date will be listed in the first column.

#### Changing the form view (New and Edit views)

Just as you can change the list view fields, you can also tell Togo which fields to show in form view and in which order.


    class BlogEntry

      include DataMapper::Resource
      include Togo::DataMapper::Model
      ... snipped ...

      list_properties :title, :date
      form_properties :title, :date, :body

    end


Associations also can be used in list and form property declarations:


    class BlogEntry

      include DataMapper::Resource
      include Togo::DataMapper::Model
      ... snipped ...

      list_properties :title, :date
      form_properties :title, :date, :body, :comments

    end

Togo also allows for displaying values returned from instance methods on your model.
This opens up customization of the list display even further.

    class BlogEntry

      include DataMapper::Resource
      include Togo::DataMapper::Model
      ... snipped ...

      list_properties :title, :date, :number_of_comments
      form_properties :title, :date, :body, :comments

      def number_of_comments
        comments.count
      end

    end


#### Configuring properties

There are some options you can change on each field individually by using the configure_property declaration.

Here you can customize the label:

    class BlogEntry

      include DataMapper::Resource
      include Togo::DataMapper::Model
      ... snipped ...

      list_properties :title, :date
      form_properties :title, :date, :body

      configure_property :title, :label => "Title (keep it short and sweet)"

    end


Each property type has it's own default form template that can be overridden simply by specifying a full path to the template (only ERB is currently supported):


    class BlogEntry

      include DataMapper::Resource
      include Togo::DataMapper::Model
      ... snipped ...

      list_properties :title, :date
      form_properties :title, :date, :body

      configure_property :title, :label => "Title (keep it short and sweet)"
      configure_property :body, :template => File.join(SITE_ROOT, 'views', 'custom_body.erb')

    end


Note we used the SITE_ROOT constant we defined in the init.rb file, how you get the full path to your template may vary depending on your setup.

See the Writing a Form Template Guide for more information. (Coming Soon)


## Configuring Togo::Admin

There are currently only a couple configuration options for Togo Admin which affect runtime, but you can also pass in any
arbitrary configuration parameters and access them through custom templates in a global config hash. In our example, let's open
init.rb and configure Togo::Admin:

    #init.rb:

    SITE_ROOT = File.dirname(File.expand_path(__FILE__))
    ... snipped ...

    Togo::Admin.configure({:site_title => "My Admin Title", :my_custom_config => "Custom Config Value"})


If you had a custom template for your property and wanted to access :my_custom_config:

    <%= config[:my_custom_config] %>


### Authentication

By default Togo is not protected by an authentication method. If you're going to run Togo on a public web server, you'll
most likely want to protect it. Luckily you can tell Togo to use any object you desire to autenticate against.

First, define any object that responds to two methods:

#### self.authenticate(username, password)

A class method that Togo Admin will call, passing in a username and password. If successful, You must pass back an instance
of your object with a property called authenticated? set to true. If authentication fails, you can still pass back an
instance of your object, but with authenticated? returning false, or can return nil.

#### authenticated?

What Togo Admin will ask an instance of your object before every request. Must return true or false.

If the Togo Admin authenticates the user successfully, it will store the instance of that object in the session and check it 
before each request to see if the user is authenticated or not.

### Example User object for authentication

Here is an trivial example using a DataMapper object to authenticate a user:


    class User

      include DataMapper::Resource
      property :id, Serial
      property :username, String
      property :password, String

      attr_accessor :authenticated

      def authenticated?
        authenticated || false
      end

      def self.authenticate(u, p)
        u = first(:username => u, :password => p)
        u.authenticated = true if u
        u
      end

    end


Note that the object does *not* have to have the Togo Model module included to work, unless you want it to.

### Enabling Authentication

Finally tell Togo Admin to authenticate against your User object by configuring the Togo::Admin
application at runtime, either in your init.rb or togo-admin-config.rb file, like so:

    Togo::Admin.configure({:auth_model => User})

It's up to you how to to authenticate the user: Local Database, LDAP, Kerberos, etc.
