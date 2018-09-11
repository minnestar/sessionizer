# Sessionizer

Sessionizer is a tool for managing session registration for unconferences. It was written for [MinneBar](http://minnestar.org/minnebar/), an unconference in Minnesota and one of the largest BarCamps in the world.

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

## Running

### Bootstrapping

You'll need to install [VirtualBox][], [Vagrant][], and [Ansible][]
first. VirtualBox and Vagrant both have Mac OS X installer packages, and
Ansible can be installed either with Homebrew or with pip, the Python
package manager.

[VirtualBox]: https://www.virtualbox.org/wiki/Downloads
[Vagrant]: http://www.vagrantup.com/downloads.html
[Ansible]: http://docs.ansible.com/intro_installation.html

Once you've got those installed, you can bootstrap the project with:

    $ cd vagrant && vagrant up

This will create the box, install the gems, create the database (if it
doesn't already exist), and start the app inside the box. To access it,
add an entry in your /etc/hosts file like the following (or do the
equivalent in dnsmasq.conf):

    192.168.100.185 sessionizer.vm

You can then visit <http://sessionizer.vm/>.

To restart the app, you can ssh into the box and run:

    $ vagrant ssh
    vagrant$ sudo service unicorn-sessionizer restart

    -- or -- 
    vagrant$ railsup

To re-run the provisioning scripts, which are idempotent, you can simply do:

    $ vagrant provision

This should bring the box back into its correct configuration if
anything has gotten messed up.

========

This app also uses Mandrill for sending emails. The account is under

user: casey at minnestar . org
pass: <inside minne* one password> (ask casey or jamie)

========

### Development (seed data)

For development, run `rake app:make_believe` to hydrate the database with sample
data. It will reset the database, create an event, participants, timeslots, 
sessions, and apply randomized participant interest. This does not run the 
scheduling algorithm.

```
 $ cd vagrant; vagrant ssh
 $ cd /srv/sessionizer
 $ bundle exec rake app:make_believe
```

If you need to restart the unicorn processes within the virtual box you
can alway use the alias `railsup`. 



### Deploying to Heroku

1. Create an application. Sessionizer runs on the default Cedar stack.
2. Add the memcache add-on: `heroku addons:add memcached:5mb`
3. Run `heroku run rake db:migrate`
4. Run `heroku run rake db:seed`
5. Set a username and password for the Sessionizer admin: `heroku config:add SESSIONIZER_ADMIN_USER=foo SESSIONIZER_ADMIN_PASSWORD=bar`
6. Set a MANDRILL_MINNESTAR_USERNAME, MANDRILL_MINNESTAR_PASSWORD
7. Create the first event by navigating to `/admin/events` or using the
   console
8. Since the app is in a git subtree (src/ directory), you need to push
   the app to heroku like this
 
from master  

```
  $ git subtree push --prefix src heroku master
```

or from master with a --force
```
  $ git push heroku `git subtree split --prefix src master`:master --force
```



### Automatic Scheduling

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
* [Justin Coyne](https://twitter.com/j_coyne)
* Cory Preus
* [Jamie Thingelstad](http://thingelstad.com/)

## License

This project is open source under the MIT license. See `LICENSE.txt` for details.
