require 'zeitwerk'
require 'active_support/inflector'

class Grape::App::Inflector < Zeitwerk::Inflector
  def camelize(basename, _abspath)
    case basename
    when 'api'
      'API'
    else
      ActiveSupport::Inflector.camelize(basename)
    end
  end
end
