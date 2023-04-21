# Activerecord::QuickRead

Makes rails go _faster_. Improve read times 4x!

### How does it work?

Skips active record instantiation, query just the results and use them as plain hashes, converted
to structs with the same attributes as your model. The structs will gracefully upgrade to full
version of your model, in the event that you need to update them.

## Installation


Install the gem and add to the application's Gemfile by executing:

    $ bundle add activerecord-quick_read

If bundler is not being used to manage dependencies, install the gem by executing:

    $ gem install activerecord-quick_read

## Usage

Use `#quick_reads` on your ActiveRecord relations (or `#quick_read` to limit 1)
Use `#quick_build` on your ActiveRecord models

First, add quickness to your model:
```
class Report < ApplicationRecord
  extend QuickReads
end
```

Then you're ready to start going faster!

It's as simple as:

```ruby
Report.where(id: params[:id]).quick_read
```

Load your batches 4x quicker:
```ruby
Report.all.in_batches { |batch| batch.quick_reads.map(&:to_h) }
```

Gracefully upgrade to a full-fledged ActiveRecord object, and even issue `update` statements:
```ruby
Report.all.quick_reads.each { |report| report.update(status: "done") if report.message = ?? }
```

It just works.

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and the created tag, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/[USERNAME]/activerecord-quick_read. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [code of conduct](https://github.com/[USERNAME]/activerecord-quick_read/blob/main/CODE_OF_CONDUCT.md).

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the Activerecord::QuickRead project's codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/[USERNAME]/activerecord-quick_read/blob/main/CODE_OF_CONDUCT.md).
