load File.expand_path('tasks/core.rake', __dir__)

begin
  require 'active_record'
  load File.expand_path('tasks/databases.rake', __dir__)
rescue LoadError
  nil
end
