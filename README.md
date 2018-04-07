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

```crystal
require "carbon"
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
