class StripeMailer < ActionMailer::Base
  default from: "support@evercam.io"
  default to: "support@evercam.io"

  def send_customer_invoice(invoice, invoice_lines, period, user_email)
    @invoice          = invoice
    @invoice_lines    = invoice_lines
    @to_user_email    = user_email
    @period           = period
    mail(to: user_email, subject: "Payment Invoice")
  end

end