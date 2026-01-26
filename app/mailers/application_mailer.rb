class ApplicationMailer < ActionMailer::Base
  default from: "L'équipe eva <#{Eva::EMAIL_CONTACT}>",
          delivery_method_options: { "version" => "v3.1", "TrackClicks" => "disabled" }
  layout "mailer"
  helper :application
end
