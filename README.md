# Fcm

## Development

I decide to create a gem because reading the instructions looks like a console task, run with this command:
```
BASED=SVQ bundle exec ruby main.rb input.txt
```
with a simple input and output.

I decided to create a type of object, Segment, to save the information of every line with information.
I see two types of data, some are accomodations and other tickets for transport.
But I prefer to begin with a one type of object and if I needed in the future split to two,  instead of create two different objects in this step.
I am using the number of words in the line to identify the data, then in normals conditions of work I would ask if we are sure about this.
Because if, for example, we have an hour to leave an accomodation, example:
```
"SEGMENT: Resort MAD 2023-02-15 -> 2023-02-17 12:00"
```
with the current code will raise an error.

I order this segments using the departure_time.
Once the segments are order we can know the initial step of every travel because the
departure place (or to field) would be the city pass like the environment variable BASED
To know the next steps I use a loop when I search the next step for:
- the field `from` the next step should be the field `to` of the previous step
- the date of arrival of the next step should be later of the departure time of the previous step
I use a loop because I don't know the number of steps in the travel.

## Doubts
In the case of transport if in the middle of the travel we change the day, that is reflected in some way?
For example:
```
SEGMENT: Flight SVQ 2023-03-02 23:40 -> BCN 02:10
```
Because if this case would be completed with more information for example:
```
SEGMENT: Flight SVQ 2023-03-02 23:40 -> BCN 2023-03-03 02:10
```
Because with the current code will raise an error.

## Installation

TODO: Replace `UPDATE_WITH_YOUR_GEM_NAME_IMMEDIATELY_AFTER_RELEASE_TO_RUBYGEMS_ORG` with your gem name right after releasing it to RubyGems.org. Please do not do it earlier due to security reasons. Alternatively, replace this section with instructions to install your gem from git if you don't plan to release to RubyGems.org.

Install the gem and add to the application's Gemfile by executing:

```bash
bundle add UPDATE_WITH_YOUR_GEM_NAME_IMMEDIATELY_AFTER_RELEASE_TO_RUBYGEMS_ORG
```

If bundler is not being used to manage dependencies, install the gem by executing:

```bash
gem install UPDATE_WITH_YOUR_GEM_NAME_IMMEDIATELY_AFTER_RELEASE_TO_RUBYGEMS_ORG
```

## Usage

```
$ cd lib/
$ BASED=SVQ bundle exec ruby main.rb input.txt
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and the created tag, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/[USERNAME]/fcm.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
