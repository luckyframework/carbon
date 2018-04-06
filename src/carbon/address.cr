require "./emailable"

class Carbon::Address
  include Carbon::Emailable

  getter name, address

  @name : String?
  @address : String

  def initialize(@address)
  end

  def initialize(@name : String, @address)
  end

  def carbon_address
    self
  end
end
