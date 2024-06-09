# Sessionizer

Sessionizer is a tool for managing session registration for unconferences. It was written for [Minnebar](http://minnestar.org/minnebar/), an unconference in Minnesota and one of the largest BarCamps in the world.

[![Build Status](http://img.shields.io/travis/minnestar/sessionizer.svg)](https://travis-ci.org/minnestar/sessionizer) [![Coveralls](http://img.shields.io/coveralls/minnestar/sessionizer.svg)](https://coveralls.io/r/minnestar/sessionizer) [![Scrutinizer](http://img.shields.io/scrutinizer/g/minnestar/sessionizer.svg)](https://scrutinizer-ci.com/g/minnestar/sessionizer/)


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

# cd into /src folder
cd /src

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

# create 'vagrant' user
createuser -s -r vagrant
```

#### Bundle exec
You're probably going to want to run all the rake tasks with `bundle exec` e.g.
```bash
bundle exec rails 
```

## Running the application
To run the application

```bash
$ cd /src
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
 $ cd src
 $ bundle exec rake app:make_believe
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
8. Since the app is in a git subtree (src/ directory), you need to push
   the app to heroku like this

from master

```
  $ git subtree push --prefix src heroku master
```

or from a specific branch with a --force
```
  $ git push heroku `git subtree split --prefix src THE_BRANCH_NAME`:master --force
```

## Automatic Scheduling

Sessionizer can automatically generate a schedule for your event based on preferences expressed by the audience and attempting not to double-book presenters.

To run the scheduler:

1. Have attendees express interest in sessions. The scheduler attempts to maximize the percentage of sessions attendees can attend.
2. Create rooms and timeslots for your event. The number of rooms * number of timeslots must be greater than the number of sessions, or the scheduler will fail.
3. Run the scheduler: `rake app:generate_schedule`. This takes a long time, so it is probably best to test it out at a low quality setting: `quality=0.001 rake app:generate_schedule`

Once the scheduler has run, you can see what it produced by visiting `/schedule`. You'll also see output on the console and it will indicate what percentage of attendees can attend the sessions they are interested in and the amount of presenter overlap (hopefully zero).

You can tweak the schedule by creating PresenterTimeslotRestrictions (if a person can only present during certain timeslots) or by manually swapping scheduled rooms after the schedule has been created (see `Session.swap_rooms`).

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

This project is open source under the MIT license. See [LICENSE](src/LICENSE.txt) for details.
