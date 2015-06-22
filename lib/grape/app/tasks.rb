load File.expand_path("../tasks/core.rake", __FILE__)

begin
  require 'active_record'
  load File.expand_path("../tasks/databases.rake", __FILE__)
rescue LoadError
end
