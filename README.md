[![Gem Version](http://img.shields.io/gem/v/increments-schedule.svg?style=flat)](http://badge.fury.io/rb/increments-schedule)
[![Dependency Status](http://img.shields.io/gemnasium/increments/increments-schedule.svg?style=flat)](https://gemnasium.com/increments/increments-schedule)
[![Build Status](https://travis-ci.org/increments/increments-schedule.svg?branch=master&style=flat)](https://travis-ci.org/increments/increments-schedule)

# Increments::Schedule

Find out our special remote days and eagerly wait for them!

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'increments-schedule'
```

And then execute:

```bash
$ bundle
```

Or install it yourself as:

```bash
$ gem install increments-schedule
```

## APIs

### Predicate Methods

* `Increments::Schedule.foundation_anniversary?(date = Date.today)`
* `Increments::Schedule.super_hanakin?(date = Date.today)`
* `Increments::Schedule.pay_day?(date = Date.today)`
* `Increments::Schedule.work_day?(date = Date.today)`
* `Increments::Schedule.remote_work_day?(date = Date.today)`
* `Increments::Schedule.rest_day?(date = Date.today)`
* `Increments::Schedule.weekend?(date = Date.today)`
* `Increments::Schedule.holiday?(date = Date.today)`
* `Increments::Schedule.summer_vacation?(date = Date.today)`
* `Increments::Schedule.winter_vacation?(date = Date.today)`

### Enumeration Methods

* `Increments::Schedule.each_foundation_anniversary(max_date = Date.today + 365)`
* `Increments::Schedule.each_super_hanakin(max_date = Date.today + 365)`
* `Increments::Schedule.each_pay_day(max_date = Date.today + 365)`
* `Increments::Schedule.each_work_day(max_date = Date.today + 365)`
* `Increments::Schedule.each_remote_work_day(max_date = Date.today + 365)`
* `Increments::Schedule.each_rest_day(max_date = Date.today + 365)`
* `Increments::Schedule.each_weekend(max_date = Date.today + 365)`
* `Increments::Schedule.each_holiday(max_date = Date.today + 365)`
* `Increments::Schedule.each_summer_vacation(max_date = Date.today + 365)`
* `Increments::Schedule.each_winter_vacation(max_date = Date.today + 365)`

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release` to create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

1. Fork it ( https://github.com/[my-github-username]/increments-schedule/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
