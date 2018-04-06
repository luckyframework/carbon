class Carbon::RecipientsList
  @to : Carbon::Email::Recipients
  @cc : Carbon::Email::Recipients?
  @bcc : Carbon::Email::Recipients?

  def initialize(@to, @cc, @bcc)
  end

  def to : Array(Carbon::Address)
    normalize(@to)
  end

  def cc : Array(Carbon::Address)
    normalize(@cc)
  end

  def bcc : Array(Carbon::Address)
    normalize(@bcc)
  end

  private def normalize(recipients : Carbon::Email::Recipients?) : Array(Carbon::Address)
    recipients = if recipients.is_a?(Array)
                   recipients
                 elsif recipients.nil?
                   [] of Carbon::Address
                 else
                   [recipients]
                 end

    recipients.map(&.carbon_address)
  end
end
