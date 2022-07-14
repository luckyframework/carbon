# Carbon

[![API Documentation Website](https://img.shields.io/website?down_color=red&down_message=Offline&label=API%20Documentation&up_message=Online&url=https%3A%2F%2Fluckyframework.github.io%2Fcarbon%2F)](https://luckyframework.github.io/carbon)

Email library written in Crystal.

![code preview](https://user-images.githubusercontent.com/22394/38457909-9f16f9fe-3a64-11e8-852c-74e31238f48b.png)

## Installation

Add this to your application's `shard.yml`:

```yaml
dependencies:
  carbon:
    github: luckyframework/carbon
```

## Adapters

- `Carbon::SendGridAdapter`- See [luckyframework/carbon_sendgrid_adapter](https://github.com/luckyframework/carbon_sendgrid_adapter).
- `Carbon::AwsSesAdapter` - See [keizo3/carbon_aws_ses_adapter](https://github.com/keizo3/carbon_aws_ses_adapter).
- `Carbon::SendInBlueAdapter` - See [atnos/carbon_send_in_blue_adapter](https://github.com/atnos/carbon_send_in_blue_adapter).
- `Carbon::MailgunAdapter` - See [atnos/carbon_mailgun_adapter](https://github.com/atnos/carbon_mailgun_adapter).
- `Carbon::SmtpAdapter` - See [oneiros/carbon_smtp_adapter](https://github.com/oneiros/carbon_smtp_adapter).
- `Carbon::SparkPostAdapter` - See [Swiss-Crystal/carbon_sparkpost_adapter](https://github.com/Swiss-Crystal/carbon_sparkpost_adapter).
- `Carbon::PostmarkAdapter` - See [makisu/carbon_postmark_adapter](https://github.com/makisu/carbon_postmark_adapter).

## Usage

### First, create a base class for your emails

```crystal
require "carbon"

# You can setup defaults in this class
abstract class BaseEmail < Carbon::Email
  # For example, set up a default 'from' address
  from Carbon::Address.new("My App Name", "support@myapp.com")
  # Use a string if you just need the email address
  from "support@myapp.com"
end
```

### Configure the mailer class

```crystal
BaseEmail.configure do |settings|
  settings.adapter = Carbon::DevAdapter.new(print_emails: true)
end
```

### Create a class for your email

```crystal
# Create an email class
class WelcomeEmail < BaseEmail
  def initialize(@name : String, @email_address : String)
  end

  to @email_address
  subject "Welcome, #{@name}!"
  header "My-Custom-Header", "header-value"
  reply_to "no-reply@noreply.com"
  # You can also do just `text` or `html` if you don't want both
  templates text, html
end
```

### Create templates

Templates go in the same folder the email is in:

- Text email: `<folder_email_class_is_in>/templates/<underscored_class_name>/text.ecr`
- HTML email: `<folder_email_class_is_in>/templates/<underscored_class_name>/html.ecr`

So if your email class is in `src/emails/welcome_email.cr`, then your
templates would go in `src/emails/templates/welcome_email/text|html.ecr`.

```
# in <folder_of_email_class>/templates/welcome_email/text.ecr
# Templates have access to instance variables and methods in the email.
Welcome, <%= @name %>!
```

```
# in <folder_of_email_class>/templates/welcome_email/html.ecr
<h1>Welcome, <%= @name %>!</h1>
```

For more information on what you can do with Embedded Crystal (ECR), see [the official Crystal documentation](https://crystal-lang.org/api/latest/ECR.html).

### Template layouts

Layouts are optional allowing you to specify how each email template looks individually.
If you'd like to have the same layout on each, you can create a layout template in
`<folder_email_class_is_in>/templates/<layout_name>/layout.ecr`

In this file, you'll yield the main email body with `<%= content %>`. Then in your `BaseEmail`, you can specify the name of the layout.

```crystal
abstract class BaseEmail < Carbon::Email
  macro inherited
    from default_from
    layout :application_layout
  end
end
```

```
# in src/emails/templates/application_layout/layout.ecr

<h1>Our Email</h1>

<%= content %>

<div>footer</div>
```

### Deliver the email

```
# Send the email right away!
WelcomeEmail.new("Kate", "kate@example.com").deliver

# Send the email in the background using `spawn`
WelcomeEmail.new("Kate", "kate@example.com").deliver_later
```

### Delay email delivery

The built-in delay uses the `deliver_later_strategy` setting set to `Carbon::SpawnStrategy`. You can create your own custom delayed strategy
that inherits from `Carbon::DeliverLaterStrategy` and defines a `run` method that takes a `Carbon::Email` and a block.

One example might be a job processor:

```crystal
# Define your new delayed strategy
class SendEmailInJobStrategy < Carbon::DeliverLaterStrategy

  # `block.call` will run `deliver`, but you can call
  # `deliver` yourself on the `email` when you need.
  def run(email : Carbon::Email, &block)
    EmailJob.perform_later(email)
  end
end

class EmailJob < JobProcessor
  def perform(email : Carbon::Email)
    email.deliver
  end
end

# configure to use your new delayed strategy
BaseEmail.configure do |settings|
  settings.deliver_later_strategy = SendEmailInJobStrategy.new
end
```

## Testing

### Change the adapter

```crystal
# In spec/spec_helper.cr or wherever you configure your code
BaseEmail.configure do
  # This adapter will capture all emails in memory
  settings.adapter = Carbon::DevAdapter.new
end
```

### Reset emails before each spec and include expectations

```crystal
# In spec/spec_helper.cr

# This gives you the `be_delivered` expectation
include Carbon::Expectations

Spec.before_each do
  Carbon::DevAdapter.reset
end
```

### Integration testing

```crystal
# Let's say we have a class that signs the user up and sends the welcome email
# that was described at the beginning of the README
class SignUpUser
  def initialize(@name : String, @email_address : String)
  end

  def run
    sign_user_up
    WelcomeEmail.new(name: @name, email_address: @email_address).deliver
  end
end

it "sends an email after the user signs up" do
  SignUpUser.new(name: "Emily", email_address: "em@gmail.com").run

  # Test that this email was sent
  WelcomeEmail.new(name: "Emily", email_address: "em@gmail.com").should be_delivered
end

# or we can just check that some emails were sent
it "sends some emails" do
  SignUpUser.new(name: "Emily", email_address: "em@gmail.com").run

  Carbon.should have_delivered_emails
end
```

### Unit testing

Unit testing is simple. Instantiate your email and test the fields you care about.

```crystal
it "builds a nice welcome email" do
  email = WelcomeEmail.new(name: "David", email_address: "david@gmail.com")
  # Note that recipients are converted to an array of Carbon::Address
  # So if you use a string value for the `to` field, you'll get an array of
  # Carbon::Address instead.
  email.to.should eq [Carbon::Address.new("david@gmail.com")]
  email.text_body.should contain "Welcome"
  email.html_body.should contain "Welcome"
end
```

> Note that unit testing can be superfluous in most cases. Instead, try
> unit testing just fields that have complex logic. The compiler will catch most
> other issues.

## Development

- `shards install`
- Make changes
- `./script/test`
- `./bin/ameba`

## Contributing

1.  Fork it ( https://github.com/luckyframework/carbon/fork )
2.  Create your feature branch (git checkout -b my-new-feature)
3.  Make your changes
4.  Run `./script/test` to run the specs, build shards, and check formatting
5.  Commit your changes (git commit -am 'Add some feature')
6.  Push to the branch (git push origin my-new-feature)
7.  Create a new Pull Request

## Contributors

- [paulcsmith](https://github.com/paulcsmith) Paul Smith - creator
