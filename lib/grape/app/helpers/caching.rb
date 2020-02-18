require 'digest'
require 'active_support/digest'
require 'active_support/cache'

# Caching support for Grape.
# "Borrowed" from [Ruby on Rails](https://github.com/rails/rails/blob/66cabeda2c46c582d19738e1318be8d59584cc5b/actionpack/lib/action_controller/metal/conditional_get.rb)
module Grape::App::Helpers::Caching
  # Sets the `etag`, or `last_modified`, or both on the response and renders a
  # "304 Not Modified" response if the request is already fresh.
  #
  # @example
  #
  #   get '/articles/:id' do
  #     article = Article.find(params[:id])
  #     fresh_when(article, public: true)
  #
  #     article
  #   end
  #
  def fresh_when(object = nil, etag: nil, last_modified: nil, **cache_control)
    etag ||= object
    return if object.blank?

    last_modified ||= object.try(:updated_at) || object.try(:maximum, :updated_at)

    etag = ActiveSupport::Digest.hexdigest(ActiveSupport::Cache.expand_cache_key(etag))
    header 'ETag', etag
    header 'Last-Modified', last_modified.httpdate if last_modified
    cache_control(**cache_control) unless cache_control.empty?

    if_modified_since = headers['If-Modified-Since']
    if_modified_since = Time.rfc2822(if_modified_since) rescue nil if if_modified_since # rubocop:disable Style/RescueModifier
    if_none_match     = headers['If-None-Match']
    return unless if_modified_since || if_none_match

    fresh = true
    fresh &&= last_modified && if_modified_since >= last_modified if if_modified_since
    fresh &&= if_none_match == etag if if_none_match
    error! 'Not Modified', 304 if fresh
  end

  # Sets the `etag` and/or `last_modified` on the response and checks it against
  # the client request. If the request doesn't match the options provided, the
  # request is considered stale and should be generated from scratch.
  # Otherwise, it's fresh and we don't need to generate anything and reply with `304 Not Modified`.
  #
  # @example:
  #
  #   get '/articles/:id' do
  #     article = Article.find(params[:id])
  #     stats = article.really_expensive_call if stale?(article)
  #   end
  #
  def stale?(object = nil, **freshness_opts)
    fresh_when(object, **freshness_opts)
    true
  end

  # Sets an HTTP 1.1 Cache-Control header. Defaults to `private`.
  #
  # @example
  #
  #   expires_in 20.minutes
  #   expires_in 3.hours, public: true
  #   expires_in 3.hours, public: true, must_revalidate: true
  #
  # This method will overwrite an existing Cache-Control header.
  # See https://www.w3.org/Protocols/rfc2616/rfc2616-sec14.html for more possibilities.
  #
  # The method will also ensure an HTTP Date header for client compatibility.
  def expires_in(seconds, public: false, must_revalidate: false, stale_while_revalidate: nil, stale_if_error: nil, extras: {})
    header 'Date', Time.now.httpdate

    cache_control(
      max_age: seconds,
      public: public,
      must_revalidate: must_revalidate,
      stale_while_revalidate: stale_while_revalidate,
      stale_if_error: stale_if_error,
      extras: extras,
    )
  end

  # Sets an HTTP 1.1 Cache-Control header of `no-cache`. This means the
  # resource will be marked as stale, so clients must always revalidate.
  # Intermediate/browser caches may still store the asset.
  def expires_now(public: false)
    cache_control(no_cache: true, public: public)
  end

  def cache_control(max_age: nil, no_cache: false, public: false, must_revalidate: false, stale_while_revalidate: nil, stale_if_error: nil, extras: nil)
    extras = extras.map {|k, v| "#{k}=#{v}" } if extras.is_a?(Hash)
    opts   = []

    if no_cache
      opts << 'public' if public
      opts << 'no-cache'
    else
      opts << "max-age=#{max_age.to_i}" if max_age
      opts << (public ? 'public' : 'private')
      opts << 'must-revalidate' if must_revalidate
      opts << "stale-while-revalidate=#{stale_while_revalidate.to_i}" if stale_while_revalidate
      opts << "stale-if-error=#{stale_if_error.to_i}" if stale_if_error
    end
    opts.concat(extras) if extras

    header 'Cache-Control', opts.join(', ')
  end
end
