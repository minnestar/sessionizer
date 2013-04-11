# Sessionizer

Sessionizer is a tool for managing session registration for unconferences. It was written for [MinneBar](http://minnestar.org/minnebar/), an unconference in Minnesota and one of the largest BarCamps in the world.

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

## Running

### Bootstrapping

TBD.

* Create seed data: `rake db:seed`

### Development 

For development, run `rake app:make_believe` to hydrate the database with sample
data. It will reset the database, create an event, participants, timeslots, 
sessions, and apply randomized participant interest. This does not run the 
scheduling algorithm.

## Deploying

Sessionizer is designed to run on Heroku, though with a little setup you should be able to get it running anywhere.

1. Create an application. Sessionizer runs on the default Cedar stack.
2. Add the memcache add-on: `heroku addons:add memcached:5mb`
3. Run `heroku run rake db:migrate`
4. Run `herok run rake db:seed`
5. Set a username and password for the Sessionizer admin: `heroku config:add SESSIONIZER_ADMIN_USER=foo SESSIONIZER_ADMIN_PASSWORD=bar`
6. Create the first event by navigating to `/admin/events`

## Automatic Scheduling

Sessionizer can automatically generate a schedule for your event based on preferences expressed by the audience and attempting not to double-book presenters.

To run the scheduler:

1. Have attendees express interest in sessions. The scheduler attempts to maximize the percentage of sessions attendees can attend.
2. Create rooms and timeslots for your event. The number of rooms * number of timeslots must be greater than the number of sessions, or the scheduler will fail.
3. Run the scheduler: `rake app:generate_schedule`. This takes a long time, so it is probably best to test it out at a low quality setting: `quality=0.001 rake app:generate_schedule`

Once the scheduler has run, you can see what it produced by visiting `/schedule`. You'll also see output on the console and it will indicate what percentage of attendees can attend the sessions they are interested in and the amount of presenter overlap (hopefully zero).

You can tweak the schedule by creating PresenterTimeslotRestrictions (if a person can only present during certain timeslots) or by manually swapping scheduled rooms after the schedule has been created (see `Session.swap_rooms`).


## Contributors

* [Luke Francl](http://luke.francl.org)
* [Paul Cantrell](http://innig.net/)
* [Ben Edwards](http://www.alttext.com/)
* [Casey Helbling](http://softwareforgood.com/team)

## License

This project is open source under the MIT license. See `LICENSE.txt` for details.
