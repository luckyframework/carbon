require "ecr"

abstract class Carbon::Email
  include Carbon::Callbacks
  alias Recipients = Carbon::Emailable | Array(Carbon::Emailable)

  abstract def subject : String
  abstract def from : Carbon::Address
  abstract def to : Array(Carbon::Address)

  def_equals subject, from, to, cc, bcc, headers, text_body, html_body

  # Set this value to `false` to prevent the email from
  # being delivered
  property? deliverable : Bool = true

  def cc
    [] of Carbon::Address
  end

  def bcc
    [] of Carbon::Address
  end

  def text_body; end

  def text_layout(content_io : IO); end

  def html_body; end

  def html_layout(content_io : IO); end

  def before_send; end

  def after_send(result); end

  getter headers

  macro inherited
    macro templates(*content_types)
      \{% for content_type in content_types %}
        def \{{ content_type }}_body : String
          content_io = IO::Memory.new
          ECR.embed "#{__DIR__}/templates/\{{ @type.name.underscore.gsub(/::/, "_") }}/\{{ content_type }}.ecr", content_io
          \{{ content_type }}_layout(content_io) || content_io.to_s
        end
      \{% end %}
    end

    # Specify an HTML template layout
    #
    # ```
    # templates html
    # layout email_layout
    # ```
    macro layout(template_name)
      def html_layout(content_io : IO)
        content = content_io.to_s
        layout_io = IO::Memory.new
        ECR.embed "#{__DIR__}/templates/\{{ template_name.id }}/layout.ecr", layout_io
        layout_io.to_s
      end
    end
  end

  @headers = {} of String => String

  macro reply_to(address)
    header "Reply-To", {{ address }}
  end

  macro header(key, value)
    def headers : Hash(String, String)
      {% if @type.methods.map(&.name).includes?(:headers.id) %}
        previous_def
      {% end %}
      @headers[{{ key }}] = {{ value }}
      @headers
    end
  end

  macro from(value)
    def from : Carbon::Address
      normalize(id_or_method({{ value }})).first
    end
  end

  macro subject(value)
    def subject : String
      id_or_method({{ value }})
    end
  end

  {% for method in [:to, :cc, :bcc] %}
    macro {{ method.id }}(value)
      def {{ method.id }} : Array(Carbon::Address)
        normalize(id_or_method(\{{ value }}))
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

  private def normalize(recipients : Carbon::Email::Recipients) : Array(Carbon::Address)
    recipients = if recipients.is_a?(Array)
                   recipients
                 else
                   [recipients]
                 end

    recipients.map(&.carbon_address)
  end

  macro inherited
    {% if @type.abstract? %}
      Habitat.create do
        setting adapter : Carbon::Adapter
        setting deliver_later_strategy : Carbon::DeliverLaterStrategy = Carbon::SpawnStrategy.new
      end
    {% end %}
  end

  macro configure
    {% raise "Make #{@type.name} abstract in order to configure it." %}
  end

  def deliver
    before_send

    if deliverable?
      response = settings.adapter.deliver_now(self)
      after_send(response)
    end
  end

  def deliver_later
    settings.deliver_later_strategy.run(self) do
      deliver
    end
  end
end
