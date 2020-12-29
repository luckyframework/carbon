class Carbon::Expectations::FailureMessage
  private getter email

  def initialize(@email : Carbon::Email)
  end

  def build
    String.build do |message|
      message << "Expected: #{email} to be delivered"
      if Carbon::DevAdapter.delivered_emails.empty?
        message << ", but no emails were delivered"
      else
        message << "\n\nTry this..."
        message << "\n\n  ▸ See what emails were delivered with 'p Carbon::DevAdapter.delivered_emails'"
      end
    end
  end
end
