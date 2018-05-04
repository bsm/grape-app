require 'grape_entity'

module Grape::App::Helpers::RespondWith
  class Errors < Grape::Entity
    expose :errors
  end

  # @param [ActiveRecord::Base] record validated record
  def respond_with(record, opts={})
    unless record.errors.empty?
      opts[:with] = Errors
      status 400
    end
    present record, opts
  end
end
