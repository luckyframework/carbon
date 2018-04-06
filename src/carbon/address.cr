require "./emailable"

class Carbon::Address
  include Carbon::Emailable

  getter name, address
  def_equals name, address

  @name : String?
  @address : String

  def initialize(@address)
  end

  def initialize(@name : String, @address)
  end

  def emailable
    self
  end
end
