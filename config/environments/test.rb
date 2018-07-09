ParliamentaryQuestions::Application.configure do
  # Settings specified here will take precedence over those in config/application.rb.

  # The test environment is used exclusively to run your application's
  # test suite. You never need to work with it otherwise. Remember that
  # your test database is "scratch space" for the test suite and is wiped
  # and recreated between test runs. Don't rely on the data there!
  config.cache_classes = true

  # Do not eager load code on boot. This avoids loading your whole application
  # just for the purpose of running a single test. If you are using a tool that
  # preloads Rails for running tests, you may have to set it to true.
  config.eager_load = false

  # Configure static asset server for tests with Cache-Control for performance.
  config.serve_static_files  = true
  config.static_cache_control = "public, max-age=3600"

  # Show full error reports and disable caching.
  config.consider_all_requests_local       = true
  config.action_controller.perform_caching = false

  # Raise exceptions instead of rendering exception templates.
  config.action_dispatch.show_exceptions = false

  # Disable request forgery protection in test environment.
  config.action_controller.allow_forgery_protection = false

  # log level
  config.log_level = :debug

  # Tell Action Mailer not to deliver emails to the real world.
  # The :test delivery method accumulates sent emails in the
  # ActionMailer::Base.deliveries array.
  config.action_mailer.delivery_method = :test

  # Print deprecation notices to the stderr.
  config.active_support.deprecation = :stderr

  # For routes accessed by gecko, we require HTTP basic auth
  # See https://developer.geckoboard.com/#polling-overview
  config.gecko_auth_username = 'test_username'

  config.after_initialize do
    PaperTrail.enabled = false
  end
  config.after_initialize do
    sending_host = ENV['SENDING_HOST'] || 'localhost'

    ActionMailer::Base.default_url_options = { host: sending_host, protocol: 'https', port:'3000'}
    ActionMailer::Base.smtp_settings = {
        address: ENV['SMTP_HOSTNAME'] || 'localhost',
        port: ENV['SMTP_PORT'] || 587,
        domain: sending_host,
        user_name: ENV['SMTP_USERNAME'] || '',
        password: ENV['SMTP_PASSWORD'] || '',
        authentication: :login,
        enable_starttls_auto: true
    }
  end
end
