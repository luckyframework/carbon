class Carbon::DevAdapter < Carbon::Adapter
  class_getter delivered_emails = [] of Carbon::Email

  def initialize(print_emails = false)
    @print_emails = print_emails
  end

  def deliver_now(email : Carbon::Email)
    @@delivered_emails << email
    if @print_emails
      print_email(email)
    end
  end

  def self.delivered?(email) : Bool
    delivered_emails.any?(&.== email)
  end

  def self.reset
    @@delivered_emails.clear
  end

  private def print_email(email : Carbon::Email)
    puts(
      "#{"To:".colorize(:green)} #{email.to}",
      "#{"From:".colorize(:green)} #{email.from}",
      "#{"Subject:".colorize(:green)} #{email.subject}",
      "#{"CC:".colorize(:green)} #{email.cc}",
      "#{"BCC:".colorize(:green)} #{email.bcc}",
      "#{"Headers:".colorize(:green)} #{email.headers}",
      "======= TEXT =======".colorize(:green),
      email.text_body,
      "======= HTML =======".colorize(:green),
      email.html_body
    )
  end
end
