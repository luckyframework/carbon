require "./emailable"

class String
  include Carbon::Emailable

  def emailable : Carbon::Address
    Carbon::Address.new(address: self)
  end
end
