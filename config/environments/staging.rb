require_relative "production"
Rails.application.routes.default_url_options[:host] = ENV.fetch("APPLICATION_HOST")

Mail.register_interceptor(
  RecipientInterceptor.new(ENV.fetch("EMAIL_RECIPIENTS"))
)

Rails.application.configure do
  # ...

  config.action_mailer.default_url_options = { host: ENV.fetch("APPLICATION_HOST") }
end
