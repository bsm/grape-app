ENV['RACK_ENV'] ||= 'test'
require 'grape-app'
require 'rack/test'
require 'active_record'
require 'active_job'

ActiveRecord::Base.configurations = { 'test' => { 'adapter' => 'sqlite3', 'database' => ':memory:' } }
ActiveRecord::Base.establish_connection :test
ActiveRecord::Base.connection.instance_eval do
  create_table :articles do |t|
    t.string :title
    t.timestamps
  end
end

class Article < ActiveRecord::Base
end
