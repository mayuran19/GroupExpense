class ApplicationMailer < ActionMailer::Base
	default from: "mail.groupexpense@gmail.com"
	layout 'mailer'
end