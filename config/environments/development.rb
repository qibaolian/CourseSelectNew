Rails.application.configure do
  # Settings specified here will take precedence over those in config/application.rb.

  # In the development environment your application's code is reloaded on
  # every request. This slows down response time but is perfect for development
  # since you don't have to restart the web server when you make code changes.
  config.cache_classes = false

  # Do not eager load code on boot.
  config.eager_load = false

  # Show full error reports and disable caching.
  config.consider_all_requests_local       = true
  config.action_controller.perform_caching = false

  #邮件配置
  host = 'course621.herokuapp.com'
  config.action_mailer.default_url_options = {host: host}
  ActionMailer::Base.delivery_method = :smtp
  config.action_mailer.perform_deliveries = true
  config.action_mailer.raise_delivery_errors = true
  config.action_mailer.default :charset => "utf-8"
  ActionMailer::Base.smtp_settings = {
      :address => "smtp.yeah.net", #邮件服务器地址
      :port => 25,
      :domain => "yeah.net", #服务器域名，如xxx@yeah.net域名就是yeah.net
      :authentication => :login,
      :user_name => "hydrogenlee",  #邮件用户名，如xxx@yeah.net用户名就是xxx
      :password => "",  #与登录密码不同，此处是客户端授权密码，切记！
  }

  # Print deprecation notices to the Rails logger.
  config.active_support.deprecation = :log

  # Raise an error on page load if there are pending migrations.
  config.active_record.migration_error = :page_load

  # Debug mode disables concatenation and preprocessing of assets.
  # This option may cause significant delays in view rendering with a large
  # number of complex assets.
  config.assets.debug = true

  # Asset digests allow you to set far-future HTTP expiration dates on all assets,
  # yet still be able to expire them through the digest params.
  config.assets.digest = true

  # Adds additional error checking when serving assets at runtime.
  # Checks for improperly declared sprockets dependencies.
  # Raises helpful error messages.
  config.assets.raise_runtime_errors = true

  # Raises error for missing translations
  # config.action_view.raise_on_missing_translations = true


  config.i18n.available_locales = ['zh-CN']
end
