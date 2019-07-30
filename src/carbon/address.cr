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

  def emailable : Carbon::Address
    self
  end

  def to_s(io : IO)
    io << to_s
  end

  def to_s : String
    if @name
      "\"#{@name}\" <#{@address}>"
    else
      @address
    end
  end
end
