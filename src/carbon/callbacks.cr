module Carbon::Callbacks
  # Runs the given method before the adapter calls `deliver_now`
  #
  # ```
  # before_send :attach_metadata
  #
  # private def attach_metadata
  #   # ...
  # end
  # ```
  macro before_send(method_name)
    before_send do
      {{ method_name.id }}
    end
  end

  # Runs the block before the adapter calls `deliver_now`
  #
  # ```
  # before_send do
  #   # ...
  # end
  # ```
  macro before_send
    def before_send
      {% if @type.methods.map(&.name).includes?(:before_send.id) %}
        previous_def
      {% else %}
        super
      {% end %}

      {{ yield }}
    end
  end

  # Runs the given method after the adapter calls `deliver_now`.
  # Passes in the return value of the adapter's `deliver_now` method.
  #
  # ```
  # after_send :mark_email_as_sent
  #
  # private def mark_email_as_sent(response)
  #   # ...
  # end
  # ```
  macro after_send(method_name)
    after_send do |object|
      {{ method_name.id }}(object)
    end
  end

  # Runs the block after the adapter calls `deliver_now`, and passes the
  # return value of the adapter's `deliver_now` method to the block.
  #
  # ```
  # after_send do |response|
  #   # ...
  # end
  # ```
  macro after_send(&block)
    {%
      if block.args.size != 1
        raise <<-ERR
        The 'after_send' callback requires exactly 1 block arg to be passed.
        Example:
          after_send { |value| some_method(value) }
        ERR
      end
    %}
    def after_send(%object)
      {% if @type.methods.map(&.name).includes?(:after_send.id) %}
        previous_def
      {% else %}
        super
      {% end %}

      {{ block.args.first }} = %object
      {{ block.body }}
    end
  end
end
