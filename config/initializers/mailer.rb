Rails.application.configure do
  #########################################
  # Configuration Related to Action Mailer
  #########################################

  config.action_mailer.delivery_method = :smtp
  # We need the application frontend url to be used in our emails
  config.action_mailer.default_url_options = { host: 'localhost', port: 3000 }
  # We load certain mailer templates from our database. This ensures changes to it is reflected immediately
  config.action_mailer.perform_caching = false
  config.action_mailer.perform_deliveries = true
  config.action_mailer.raise_delivery_errors = true

  # Config related to smtp
  smtp_settings = {
    address: ENV.fetch('SMTP_ADDRESS', 'smtp.mailgun.org'),
    port: ENV.fetch('SMTP_PORT', 465)
  }

  smtp_settings[:authentication] = ENV.fetch('SMTP_AUTHENTICATION', 'login').to_sym if ENV['SMTP_AUTHENTICATION'].present?
  smtp_settings[:domain] = 'smtp.mailgun.org'
  smtp_settings[:user_name] = 'chatwoot@mg.parent-staging.schooleducation.online'
  smtp_settings[:password] = '0c480788cae4e18f09e6e4f8ae10a5d8-c4d287b4-eae4494f'
  smtp_settings[:enable_starttls_auto] = ActiveModel::Type::Boolean.new.cast(ENV.fetch('SMTP_ENABLE_STARTTLS_AUTO', true))
  smtp_settings[:openssl_verify_mode] = 'NONE'
  smtp_settings[:ssl] = ActiveModel::Type::Boolean.new.cast(true)
  smtp_settings[:tls] = ActiveModel::Type::Boolean.new.cast(ENV.fetch('SMTP_TLS', true)) if ENV['SMTP_TLS']

  config.action_mailer.delivery_method = :smtp
  config.action_mailer.smtp_settings = smtp_settings
  # You can use letter opener for your local development by setting the environment variable
  # config.action_mailer.delivery_method = :letter_opener if Rails.env.development? && ENV['LETTER_OPENER']

  #########################################
  # Configuration Related to Action MailBox
  #########################################

  # Set this to appropriate ingress service for which the options are :
  # :relay for Exim, Postfix, Qmail
  # :mailgun for Mailgun
  # :mandrill for Mandrill
  # :postmark for Postmark
  # :sendgrid for Sendgrid
  # config.action_mailbox.ingress = ENV.fetch('RAILS_INBOUND_EMAIL_SERVICE', 'relay').to_sym
end
