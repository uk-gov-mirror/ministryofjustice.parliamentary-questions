require File.expand_path('boot', __dir__)
$LOAD_PATH << File.expand_path('../lib', __dir__)

require 'pq_state'
require 'pq_state/transition'
require 'pq_state/state_machine'
require 'pq_state/progress_changer'

require 'csv'
require 'rails/all'

# This require is necessary to avoid a class error in logstasher.
# This is fixed in HEAD but not currently released in 0.6.1
require 'action_mailer/log_subscriber'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(:default, Rails.env)

module ParliamentaryQuestions
  class Application < Rails::Application
    # Application Title (Populates <title>)
    config.app_title = 'Parliamentary Questions'

    # Proposition Title (Populates proposition header)
    config.proposition_title = 'PQ Tracker'

    # Current Phase (Sets the current phase and the colour of phase tags)
    # Presumed values: alpha, beta, live
    config.phase = 'live'

    # Product Type (Adds class to body based on service type)
    # Presumed values: information, service
    config.product_type = 'service'

    # Feedback URL (URL for feedback link in phase banner)
    config.feedback_url = '#'

    # Custom directories with classes and modules you want to be autoloadable.
    config.eager_load_paths << Rails.root.join('lib')

    config.encoding = 'utf-8'

    # Configure sensitive parameters which will be filtered from the log file.
    config.filter_parameters += [:password]

    # config.assets.paths << "#{Rails}/vendor/assets/fonts"
    config.eager_load_paths << Rails.root.join('app', 'assets', 'fonts')
    config.eager_load_paths += %w[app/assets/images]
    config.eager_load_paths += %w[app/assets/javascripts]
    config.eager_load_paths += %w[app/assets/stylesheets]
    config.eager_load_paths += %w[app/assets/stylesheets/moj]
    config.eager_load_paths += %w[app/assets/stylesheets/vendor]

    config.generators do |g|
      g.template_engine :erb
    end

    config.exceptions_app = routes

    # Statsd
    $statsd = Statsd.new 'localhost', 8125

    Sentry.init do |config|
      config.dsn = ENV['SENTRY_DSN']
      config.breadcrumbs_logger = [:active_support_logger]
    end
  end
end

require 'settings'
