class ApplicationMailer < ActionMailer::Base
  default from: "L'équipe eva <#{Eva::EMAIL_CONTACT}>",
          delivery_method_options: { "TrackClicks" => "disabled" }
  layout "mailer"
  helper :application
end
