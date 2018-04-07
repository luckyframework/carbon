# Carbon

Email library written in Crystal.

## Installation

Add this to your application's `shard.yml`:

```yaml
dependencies:
  carbon:
    github: luckyframework/carbon
```

## Usage

### First, create a `BaseEmail` class

```crystal
require "carbon"

abstract class BaseEmail < Carbon::Email
  # Set up a default from address
  from Carbon::Address.new("My App Name", "support@myapp.com")
  # Use a string if you just need the email address
  from "support@myapp.com"
end
```

### Configure the mailer class

```crystal
BaseEmail.configure do
  settings.adapter = Carbon::SendGridAdapter.new(api_key: "SEND_GRID_API_KEY")
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

* Text email: `<folder_email_class_is_in>/templates/<underscored_class_name>/text.ecr`
* HTML email: `<folder_email_class_is_in>/templates/<underscored_class_name>/html.ecr`

So if your email class is in `src/my_app/emails/welcome_email.cr`, then your
templates would go in `src/my_app/emails/welcome_email/text|html.ecr`.

```
# in <folder_of_email_class>/templates/welcome_email/text.ecr
# Templates have access to instance variables and methods in the email.
Welcome, #{@name}!
```

```
# in <folder_of_email_class>/templates/welcome_email/html.ecr
<h1>Welcome, #{@name}!</h1>
```

### Deliver the email

```
# Send the email!
WelcomeEmail.new("Kate", "kate@example.com").deliver_now
```

## Development

* `shards install`
* Make changes
* `crystal spec -D skip-integration` (will skip sending test emails to SendGrid)
* `crystal spec` requires a `SEND_GRID_API_KEY` ENV variable. Set this in a .env file:

```
# in .env
# If you want to run tests that actually test emails against the SendGrid server
SEND_GRID_API_KEY=get_from_send_grid
```

## Contributing

1.  Fork it ( https://github.com/luckyframework/carbon/fork )
2.  Create your feature branch (git checkout -b my-new-feature)
3.  Commit your changes (git commit -am 'Add some feature')
4.  Push to the branch (git push origin my-new-feature)
5.  Create a new Pull Request

## Contributors

* [paulcsmith](https://github.com/paulcsmith]) Paul Smith - creator, maintainer
