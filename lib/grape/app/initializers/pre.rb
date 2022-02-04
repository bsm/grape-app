# Configure ActiveSupport defaults
# https://github.com/rails/rails/blob/main/railties/lib/rails/application/configuration.rb
ActiveSupport.tap do |c|
  c.to_time_preserves_timezone = true
  c.utc_to_local_returns_utc_offset_times = true
end
ActiveSupport::Digest.hash_digest_class = OpenSSL::Digest::SHA256
ActiveSupport::KeyGenerator.hash_digest_class = OpenSSL::Digest::SHA256 if ActiveSupport::KeyGenerator.respond_to?(:hash_digest_class=)
ActiveSupport::MessageEncryptor.use_authenticated_message_encryption = true
ActiveSupport::IsolatedExecutionState.isolation_level = :thread if defined?(ActiveSupport::IsolatedExecutionState)
Digest::UUID.use_rfc4122_namespaced_uuids = true if Digest::UUID.respond_to?(:use_rfc4122_namespaced_uuids=)

# Set default time-zone
begin
  TZInfo::DataSource.get
rescue TZInfo::DataSourceNotFound => e
  raise e.exception "tzinfo-data is not present. Please add gem 'tzinfo-data' to your Gemfile and run bundle install"
end
require 'active_support/core_ext/time/zones'
Time.zone_default = Time.find_zone!('UTC')

# Add default I18n paths and set default locale
I18n.load_path += Dir[Grape::App.root.join('config', 'locales', '*.{rb,yml}').to_s]
I18n.default_locale = :en

if Grape::App.config.raise_on_missing_translations
  handler = Class.new(I18n::ExceptionHandler) do
    def call(exception, *)
      raise exception.to_exception if exception.is_a?(I18n::MissingTranslation)

      super
    end
  end
  I18n.exception_handler = handler.new
end

# Configure ActiveRecord defaults
# https://github.com/rails/rails/blob/main/railties/lib/rails/application/configuration.rb
if defined?(ActiveRecord)
  if ActiveRecord.respond_to?(:default_timezone=)
    ActiveRecord.default_timezone = :utc
  else
    ActiveRecord::Base.default_timezone = :utc
  end

  if ActiveRecord.respond_to?(:legacy_connection_handling=)
    ActiveRecord.legacy_connection_handling = false
  else
    ActiveRecord::Base.legacy_connection_handling = false
  end

  ActiveRecord.tap do |c|
    c.verify_foreign_keys_for_fixtures = true if c.respond_to?(:verify_foreign_keys_for_fixtures=)
  end

  ActiveRecord::Base.tap do |c|
    c.belongs_to_required_by_default = true
    c.cache_versioning = true
    c.collection_cache_versioning = true
    c.has_many_inversing = true
    c.partial_inserts = false if c.respond_to?(:partial_inserts=)
    c.automatic_scope_inversing = true if c.respond_to?(:automatic_scope_inversing=)
  end
end

# Configure ActiveJob defaults
# https://github.com/rails/rails/blob/main/railties/lib/rails/application/configuration.rb
if defined?(ActiveJob)
  ActiveJob::Base.tap do |c|
    c.retry_jitter = 0.15
  end
end
