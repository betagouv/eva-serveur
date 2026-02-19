class ApplicationMailer < ActionMailer::Base
  default from: "L'équipe eva <#{Eva::EMAIL_CONTACT}>"
  layout "mailer"
  helper :application
end
