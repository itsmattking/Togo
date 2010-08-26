# Introducing Togo

Togo is a CMS framework. It also includes a simple web framework based on Rack that can be used to make micro-webapps (similar to Sinatra).
However the goal of Togo is to be a modular system that can be used with any Ruby ORM framework, giving you a complete CMS system for free.

## Installation

    gem install togo

## Tutorial

Togo works by a simply including a line in your model definition (currently, Togo only works for DataMapper). By including Togo in your model,
it will be automatically integrated into the Togo admin application, giving you all the CRUD actions as well as listing and search. It even
works with associations.

### Setting up a simple application

We'll use a combination of Sinatra, DataMapper and Sqlite for our tutorial. You actually don't need Sinatra to run the Togo admin application, however this
gives a good idea of how Togo can be used in conjuction with an existing project.

You'll need the following gems installed:

pre. dm-core dm-serializer sinatra dm-sqlite3-adapter

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

Now you have a complete CMS system for free, but you can also customize what fields are used, what order they appear, and even 
use your own templates for complete customization.

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

pre. list_properties :date, :title

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