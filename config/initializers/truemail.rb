Truemail.configure do |config|
  config.verifier_email = 'contact@eva.beta.gouv.fr'

  config.default_validation_type = :mx
  config.not_rfc_mx_lookup_flow = true
end
