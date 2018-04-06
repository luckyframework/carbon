require "./emailable"

class String
  include Carbon::Emailable

  def emailable
    Carbon::Address.new(address: self)
  end
end
