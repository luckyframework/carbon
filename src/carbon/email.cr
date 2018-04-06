require "ecr"

abstract class Carbon::Email
  alias Recipients = Carbon::Emailable | Array(Carbon::Emailable)

  abstract def subject : String
  abstract def from : Carbon::Emailable
  abstract def to : Recipients

  def cc; end

  def bcc; end

  def text_body; end

  def html_body; end

  @headers = {} of String => String

  def headers
    @headers
  end

  def recipients : RecipientsList
    RecipientsList.new(to: to, cc: cc, bcc: bcc)
  end

  macro inherited
    macro templates(*content_types)
      \{% for content_type in content_types %}
        def \{{ content_type }}_body : String
          io = IO::Memory.new
          ECR.embed "#{__DIR__}/templates/\{{ @type.name.underscore }}/\{{ content_type }}.ecr", io
          io.to_s
        end
      \{% end %}
    end
  end

  macro header(key, value)
    def headers : Hash(String, String)
      super
      @headers[key] = value
      @headers
    end
  end

  macro from(value)
    def from : Carbon::Emailable
      id_or_method({{ value }})
    end
  end

  macro subject(value)
    def subject : String
      id_or_method({{ value }})
    end
  end

  {% for method in [:to, :cc, :bcc] %}
    macro {{ method.id }}(value)
      def {{ method.id }} : Carbon::Email::Recipients
        id_or_method(\{{ value }})
      end
    end
  {% end %}

  macro id_or_method(value)
    {% if value.is_a?(SymbolLiteral) %}
      {{ value.id }}
    {% else %}
      {{ value }}
    {% end %}
  end

  macro inherited
    {% if @type.abstract? %}
      Habitat.create do
        setting adapter : Carbon::Adapter
      end
    {% end %}
  end

  macro configure
    {% raise "Make #{@type.name} abstract in order to configure it." %}
  end

  def deliver
    settings.adapter.deliver_now(self)
  end
end
