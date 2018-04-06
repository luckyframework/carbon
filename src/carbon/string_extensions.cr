require "./emailable"

class String
  include Carbon::Emailable

  def carbon_address
    Carbon::Address.new(self)
  end
end
