# Sessionizer

Sessionizer is a tool for managing session registration for unconferences. It was written for [Minnebar](http://minnestar.org/minnebar/), an unconference in Minnesota and one of the largest BarCamps in the world.

[![Scrutinizer](http://img.shields.io/scrutinizer/g/minnestar/sessionizer.svg)](https://scrutinizer-ci.com/g/minnestar/sessionizer/)

## Features

* Session creation and editing by participants
* Sessions with multiple presenters
* Participants can express interest in sessions
* Collaborative recommendation engine for recommending sessions based on similarity of interest
* Automatic scheduling algorithm that uses simulated annealing to minimize presenter overlap an maximize attendee attendance preferences
* Mobile optimized display of schedule
* iCalendar feed of schedule
* Administrative backend for editing sessions
* Export of data for various purposes

## Application setup

```bash
# clone the repo
git clone git@github.com:minnestar/sessionizer.git
cd sessionizer

# install correct ruby version
asdf install ruby # OR
rbenv install # OR
rvm install

# install bundler
gem install bundler

# install ruby gems
bundle install

# database setup
rails db:setup
```

### One-time setup
```
# create timeslots
bundle exec rails app:create_timeslots

# create rooms
bundle exec rails app:create_rooms
```

### Troubleshooting setup

#### Postgres
If you run into issues setting up the database:
```bash
# create 'postgres' user
createuser -s -r postgres

# create 'sessionizer_development' database
createdb sessionizer_development
```

#### Bundle exec
You're probably going to want to run all the rake tasks with `bundle exec` e.g.
```bash
bundle exec rails 
```

## Running the application
To run the application

```bash
$ rails s
```

Then you can access the app at http://127.0.0.1:3000.

### Seeding data for development

For development, run `rake app:make_believe` to hydrate the database with sample
data. It will reset the database, create an event, participants, timeslots,
sessions, and apply randomized participant interest. This does not run the
scheduling algorithm.

Locally:

```
 $ bundle exec rake app:make_believe
```

## Testing the application

The full test suite can be run with:
```
rails spec
```

## Deploying to Heroku

1. Create an application. Sessionizer runs on the default `heroku-18` stack.
2. Add the memcache add-on: `heroku addons:add memcached:5mb`
3. Run `heroku run rake db:migrate`
4. Run `heroku run rake db:seed`
5. Set a username and password for the Sessionizer admin: `heroku config:add SESSIONIZER_ADMIN_USER=foo SESSIONIZER_ADMIN_PASSWORD=bar`
6. Set a MANDRILL_MINNESTAR_USERNAME, MANDRILL_MINNESTAR_PASSWORD - These can be omitted if this app is for testing.
7. Create the first event by navigating to `/admin/events` or using the
   console
8. To deploy the app to heroku:

```
  $ git push heroku main
```

## Generating a schedule

See [SCHEDULING.MD](doc/SCHEDULING.md) for details and instructions.

## Code of Conduct

Minnestar is dedicated to providing a harassment-free experience for everyone. All conversations and discussions on GitHub (code, commit comments, issues, pull requests) must be respectful and harassment-free. By contributing to this project, you are agreeing to the [Code of Conduct](CODE_OF_CONDUCT.md).

## Contributors

* [Luke Francl](http://luke.francl.org)
* [Paul Cantrell](http://innig.net/)
* [Ben Edwards](http://www.alttext.com/)
* [Casey Helbling](http://softwareforgood.com/team)
* [Justin Coyne](https://twitter.com/j_coyne)
* Cory Preus
* [Jamie Thingelstad](http://thingelstad.com/)
* [Matt Decuir](https://experimatt.com/)

## License

This project is open source under the MIT license. See [LICENSE](LICENSE.txt) for details.
