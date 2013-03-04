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

TBD.

* Create seed data: `rake db:seed`


## Deploying

Sessionizer is designed to run on Heroku, though with a little setup you should be able to get it running anywhere.

1. Create an application. Sessionizer runs on the default Cedar stack.
2. Add the memcache add-on: `heroku addons:add memcached:5mb`
3. Run `heroku run rake db:migrate`
4. Run `herok run rake db:seed`
5. Set a username and password for the Sessionizer admin: `heroku config:add SESSIONIZER_ADMIN_USER=foo SESSIONIZER_ADMIN_PASSWORD=bar`
6. Create the first event by navigating to `/admin/events`

## Contributors

* [Luke Francl](http://luke.francl.org)
* [Paul Cantrell](http://innig.net/)
* [Ben Edwards](http://www.alttext.com/)
* [Casey Helbling](http://softwareforgood.com/team)

## License

This project is open source under the MIT license. See `LICENSE.txt` for details.
