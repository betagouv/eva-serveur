Truemail.configure do |config|
  config.verifier_email = Eva::EMAIL_CONTACT

  config.default_validation_type = :mx
  config.not_rfc_mx_lookup_flow = true
end
