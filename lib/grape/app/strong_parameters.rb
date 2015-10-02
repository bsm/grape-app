require 'hashie/mash'
require 'grape/app'

# Inspired by ActionController::Parameters
module Grape::App::StrongParameters

  def permitted?
    @_permitted
  end

  def permit!
    each_pair do |_, value|
      case value
      when Array
        value.each {|v| v.permit! if v.respond_to? :permit! }
      else
        value.permit! if value.respond_to? :permit!
      end
    end

    @permitted = true
    self
  end

end

Hashie::Mash.send :include, Grape::App::StrongParameters
