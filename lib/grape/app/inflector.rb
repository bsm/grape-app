require 'zeitwerk'
require 'active_support/inflector'

class Grape::App::Inflector < Zeitwerk::Inflector
  def camelize(basename, _abspath)
    case basename
    when 'api'
      'API'
    else
      ActiveSupport::Inflector.classify(basename)
    end
  end
end
