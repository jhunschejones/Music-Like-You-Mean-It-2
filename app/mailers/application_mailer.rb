class ApplicationMailer < ActionMailer::Base
  default(
    from: "Josh [Music Like You Mean It] <contact@musiclikeyoumeanit.com>",
    content_type: "text/html"
  )
  layout "mailer"
end
