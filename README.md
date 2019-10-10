# ActiveRecord::FindEachOrdered

Behave's like ActiveRecord's [#find_each](https://api.rubyonrails.org/classes/ActiveRecord/Batches.html#method-i-find_each) method,
but allows sorting by a column other than the primary key.

There are times when you need to load a large number of records, but sorting
by the primary key is undesired, or prohibitely expensive. Sorting by the
primary key may cause the database planner to avoid an index that would otherwise
be more helpful.


## Installation

Add this line to your application's Gemfile:

```ruby
gem 'activerecord-find_each_ordered'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install activerecord-find_each_ordered

## Usage

```
yesterday = 1.day.ago
Item.
  where(purchased_at: (yesterday.beginning_of_day..yesterday.end_of_day)).
  find_each_ordered(:purchased_at, batch_size: 500) do |item|

  # work with each item instance
end
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in the gemspec, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/joshuaflanagan/activerecord-find_each_ordered.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
