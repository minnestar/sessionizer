# Minnebar Scheduling
The process to generate a schedule for Minnebar takes time, and involves many steps and people.

### Rough timeline
* **6-8 weeks out**: Create an event in [Sessionizer Admin](https://sessions.minnestar.org/admin/events/)
* **4-6 weeks out**: Have attendees start creating & expressing interest in sessions
* **1 week out**: Start gathering presenter time constraints
* **4 days out**: Generate draft schedule ([this process](#instructions))
* **3 days out**: Finalize schedule
* **2 days out**: Assign rooms
* **1 day out**: Field last minute cancelations + schedule and room requests.
* **Day of event**: Minnebar

# Instructions
Instructions on how to generate a schedule for Minnebar.

1. Pull latest prod data
2. Set timeslots
3. Gather schedule constraints
4. Generate schedule
5. Upload schedule to prod

## 1. Pull latest prod data
```bash
src/bin/pull-database-from-production
```

## 2. Set timeslots
Update and/or generate time slots.

### Before running
Spot check them under `task :create_timeslots` in `app.rake` and make any adjustments needed.

```bash
# local
bundle exec rails app:create_timeslots

# prod
heroku run rails app:create_timeslots
```

### After running

Spot check them again.
* You can view the timeslots (even though there are no sessions on the schedule yet) at:
  * **Local**: http://127.0.0.1:3000/schedule?preview=1
  * **Prod**: https://sessions.minnestar.org/schedule?preview=1
* **Note**: You must be logged in (using prod credentials) to view the page.
* **Note**: It's _possible_ (but not necessarily recommended) to manually edit timeslots via the admin panel at this URL:
https://sessions.minnestar.org/admin/events/{EVENT_ID}/timeslots

## 3. Gather schedule constraints
You'll need to gather presenter/session scheduling constraints and save them to a csv file for this step.
* See `task :configure_sessions` in `app.rake` for documentation on the csv file and format.

**Important notes**:
* **This needs to happen _before_ the schedule gets generated.**
* Ideally this process has started at least a few days in advance.
* If time constraint requests come through _after_ a schedule has been set, you'll want to "freeze" the other sessions (manually via the rails console). Paul has a recipe for this.

## 4. Generate schedule
The `bin/schedule` script will carry out the entire schedule generation process.

* It takes two parameters
  1. Schedule constraints
  2. File name to save the generated schedule output
* And will carry out these steps
  1. Pull prod data
  2. Analyze schedule quality
  3. Read scheduling constraints
  4. Generate & refine schedule
  5. Export the schedule

To run the script:

```bash
bin/schedule path/to/schedule-constraints.csv path/to/generated-schedule-output.json
```

Once generated, you can access a preview at.
* **Local**: http://127.0.0.1:3000/schedule?preview=1
* **Prod**: https://sessions.minnestar.org/schedule?preview=1

**Note**: You must be logged in (using prod credentials) to view the page.

## 5. Upload schedule to prod
Once the schedule looks good, you can upload it to prod with `app:import_schedule`, like so:

```bash
heroku run rails app:import_schedule < path/to/exported-schedule-file.json
```

## 6. Assigning rooms (happens later)
**This typically doesn't happen until the day before the event.**

* Available rooms are statically defined under `task :create_rooms` in `app.rake`.
* **Note**: Reassigning rooms is much easier than reassigning time slots.

# Other notes

## How to read the schedule generation output
The rake task ouput will change every time it gets run (whether manually or via the script). But it always starts from the "best" version from the previous run.
```
bundle exec rails app:generate_schedule
```

In the very long output, lines that look like this are meaningful:

>  Schedule
  | quality vs. random = 85.750% (0% is no better than random; 100% is unachievable; > 50% is good)
  | absolute satisfaction = 94.857% of impossibly perfect schedule
  | presenter score = 100.000% (if < 100 then presenters have conflicts)

## Additional scripts & tasks
`app.rake` contains a long list of rake tasks and documentation that may be helpful:

```bash
rake app:analyze_scheduler_input_quality    # print a summary of data that will affect the quality of...
rake app:assign_rooms                       # assign scheduled sessions to rooms
rake app:clear_schedule                     # clear the current schedule (DANGER: Irreversible
rake app:configure_sessions[config_file]    # read schedule constraints and session deletions from a ...
rake app:create_remote_timeslots_and_rooms  # set up multi-day timeslots for a remote event
rake app:create_rooms                       # create default rooms for most recent event
rake app:create_timeslots                   # create default timeslots for the most recent event
rake app:export_schedule                    # export schedule for import to another node (for running...
rake app:generate_schedule                  # Create a schedule for the current event
rake app:import_schedule                    # import schedule generated by app:export_schedule
rake app:make_believe                       # Reset and hydrate the database with dummy data
rake app:presentationize                    # add a Presentation for each Session with the session ow...
rake app:presenter                          # add a presenter to a session
rake app:show_restrictions                  # show restrictions for current event
rake app:template                           # Applies the template supplied by LOCATION=(/path/to/tem...
rake app:update                             # Update configs and some other initially generated files...
```

For the most current list, run `rake -T`.

## Old Automatic Scheduling notes from README (synthesize & remove these later)

Sessionizer can automatically generate a schedule for your event based on preferences expressed by the audience and attempting not to double-book presenters.

To run the scheduler:

1. Have attendees express interest in sessions. The scheduler attempts to maximize the percentage of sessions attendees can attend.
2. Create rooms and timeslots for your event. The number of rooms * number of timeslots must be greater than the number of sessions, or the scheduler will fail.
3. Run the scheduler: `rake app:generate_schedule`. This takes a long time, so it is probably best to test it out at a low quality setting: `quality=0.001 rake app:generate_schedule`

Once the scheduler has run, you can see what it produced by visiting `/schedule`. You'll also see output on the console and it will indicate what percentage of attendees can attend the sessions they are interested in and the amount of presenter overlap (hopefully zero).

You can tweak the schedule by creating PresenterTimeslotRestrictions (if a person can only present during certain timeslots) or by manually swapping scheduled rooms after the schedule has been created (see `Session.swap_rooms`).