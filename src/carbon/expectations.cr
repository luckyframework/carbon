module Carbon::Expectations
  struct BeDeliveredExpectation
    def match(email : Carbon::Email) : Bool
      Carbon::DevAdapter.delivered?(email)
    end

    def failure_message(email)
      FailureMessage.new(email).build
    end

    def negative_failure_message(email)
      "Expected: #{email} not to be delivered"
    end
  end

  class FailureMessage
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

  private def be_delivered
    BeDeliveredExpectation.new
  end
end
