# frozen_string_literal: true

class ApplicationMailer < ActionMailer::Base
  default from: "L'équipe eva <contact@eva.beta.gouv.fr>"
  layout 'mailer'
end
