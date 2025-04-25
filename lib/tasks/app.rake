# -*- coding: utf-8 -*-
require 'csv'

namespace :app do

  desc 'create default timeslots for the most recent event'
  task create_timeslots: :environment do
    event.create_default_timeslots
  end

  desc 'create default rooms for most recent event. Will nuke old rooms.'
  task :create_rooms => :environment do
    event.rooms.destroy_all

    rooms = [
      # { name: 'Alaska',           capacity: 96 }, # Used for daycare in 2025
      { name: 'Bde Maka Ska',    capacity: 100 },
      # { name: 'Cabin',           capacity: 9 },
      # { name: 'California',      capacity: 16 },
      { name: 'Challenge',       capacity: 24 }, 
      # { name: 'Cottage',         capacity: 8 },
      { name: 'Discovery',        capacity: 23 }, # no video recording
      { name: 'Florida',         capacity: 12 }, # TV, no projector
      { name: 'Gandhi',          capacity: 23 }, # Previously used for daycare; no video recording
      { name: 'Georgia',         capacity: 12 }, # TV, no projector
      { name: 'Harriet',         capacity: 100 },
      # { name: 'Kansas',          capacity: 10 }, # TV, no projector
      { name: 'Learn',           capacity: 24 },
      { name: 'Louis Pasteur',   capacity: 18 },
      # { name: 'Maryland',        capacity: 10 },
      { name: 'Minnetonka',      capacity: 100 },
      # { name: 'Nebraska',        capacity: 10 },
      # { name: 'Nevada',          capacity: 16 },
      # { name: 'New York',        capacity: 10 },
      { name: 'Nokomis',         capacity: 100 },
      # { name: 'Oklahoma',        capacity: 8 },
      # { name: 'Oregon',          capacity: 12 },
      # { name: 'Pennsylvania',    capacity: 10 },
      { name: 'Proverb-Edison',  capacity: 48 },
      # { name: 'South Carolina',  capacity: 6 },
      { name: 'Stephen Leacock', capacity: 23 }, # Previously used for daycare; no video recording
      { name: 'Tackle',          capacity: 23 }, # no video recording
      { name: 'Texas',           capacity: 16 },
      { name: 'Theater',         capacity: 250 },
      # { name: 'Washington',      capacity: 7 },
      { name: 'Zeke Landres',    capacity: 40 },

      # –––––– Suboptimal rooms, reserved for more dire need ––––––
      # { name: 'Brand',           capacity: 75 },
    ]

    Room.transaction do
      rooms.each do |room|
        event.rooms.create!(room)
      end
    end
  end


  desc 'set up multi-day timeslots for a remote event'
  task create_remote_timeslots_and_rooms: :environment do
    session_length = 25.minutes
    event = Event.current_event
    event.timeslots.destroy_all
    event.rooms.destroy_all

    dates = [
      '2020-10-6',
      '2020-10-8',
      '2020-10-10',
      '2020-10-13',
      '2020-10-15',
      '2020-10-17',
    ]
    times = [
      '9:00',
      '9:30',
      '10:00',
      '10:30',
      '11:00',
      '11:30',
    ]
    Timeslot.transaction do
      dates.each.with_index do |date, day_num|
        times.each.with_index do |time, session_num|
          start_time = Time.zone.parse("#{date} #{time}")
          event.timeslots.create!(
            title: "Day #{day_num + 1} Session #{session_num + 1}",
            starts_at: start_time,
            ends_at: start_time + session_length,
            schedulable: true
          )
        end
      end
    end
    event.timeslots.each do |slot|
      puts "Timeslot ##{slot.id}: #{slot.to_s(with_day: true)}"
    end

    rooms = [
        { name: 'Sessions Track', capacity: 2 },
        { name: 'Hallway Track', capacity: 1 },  # Preferentially schedules sessions in the Sessions Track
    ]
    Room.transaction do
      rooms.each do |room|
        event.rooms.create!(room)
      end
    end
  end


  desc 'add a Presentation for each Session with the session owner, if it does not have one'
  task :presentationize => :environment do
    Session.all.each do |session|
      if session.presentations.empty?
        session.presentations.create!(:participant => session.participant)
      end
    end
  end

  desc 'add a presenter to a session'
  task :presenter => :environment do
    session = Session.find(ENV['SESSION'])

    if ENV['EMAIL']
      participant = Participant.find(email:ENV['EMAIL']).first
    elsif ENV['PARTICIPANT']
      participant = Participant.find(ENV["PARTICIPANT"])
    end

    # NOTE! Heroku does NOT like env vars with spaces in them, even when quoted. Escape spaces with \
    if participant.nil? && ENV['NAME']
      participant = Participant.new(:name => ENV['NAME'], :email => ENV['EMAIL'])

      participant.save(false) # ignore missing email addy

      puts "Created new participant #{participant.id}#{participant.email.blank? ? ' (without an email address!)' : ''}"
    end

    session.presentations.create!(:participant => participant)
    puts "#{participant.name} (#{participant.id}) is now associated with #{session.title}"
  end

  desc 'read schedule constraints and session deletions from a CSV file'
  task :configure_sessions, [:config_file] => :environment do |_, args|
    if args[:config_file].blank?
      STDERR.puts 'Usage:

          rails "app:configure_sessions[path/to/constraints.csv]"

        The CSV file must open with a header line with the following columns:

          Name               Presenter or session name (must strictly match for deletion)
          Presenter URL
          Session URL
          Constraints        See below
          Notes              For humans; not parsed

        The “Constraints” column accepts the following syntaxes:

          >10:00am           Session must start at or after the given time
          <12:00pm           Session must end at or before the given time
          >1:00pm, <3:00pm   Session must fall entirely within give time range
          @2:00pm            Session must be in the timeslot that includes the given time
          # 1 2 3            Session must be in one of these specific timeslot ids
          manual             Do not let sessionizer schedule this session
          delete             Soft-delete session by assigning to a nonexistent event

        WARNING: This task removes all existing presenter-timeslot restrictions for the
                 current event, so your CSV should be a complete list of ALL the restrictions.
      '

      exit 1
    end

    puts
    puts "Clearing existing restrictions for #{event}..."
    PresenterTimeslotRestriction.where(timeslot: Event.current_event.timeslot_ids).destroy_all
    puts

    CSV.foreach(args[:config_file], headers: true) do |row|
      def resolve_url(url, model_class)
        presenter = unless url.blank?
          unless url.strip =~ %r{https://sessions.minnestar.org/#{model_class.model_name.route_key}/(\d+)}
            raise "Unable to parse #{model_class} URL: #{url}"
          end
          model_class.find($1)
        end
      end

      presenter = resolve_url(row["Presenter URL"], Participant)
      session   = resolve_url(row["Session URL"], Session)

      puts "Presenter:     #{presenter&.name || '–'}"
      puts "Session:       #{session&.title || '–'}"
      puts "Intended name: #{row['Name']}"
      puts "Notes:         #{row['Notes']}"

      if presenter && session
        unless session.presenters.include?(presenter)
          raise "The participant is not one of the presenters of the given session"
        end
      end

      if session && session.event_id.abs != event.id
        raise "Session does not belong to the current event: #{session}"
      end

      constraints = (row["Constraints"] || '').strip.downcase
      if constraints.blank?
        puts
        print "    WARNING: no constraints specified"
      elsif constraints == 'manual'
        unless session
          raise "Manual scheduling requires that you specify a specific Session URL"
        end
        puts "    Manually scheduled; sessionizer will not assign time or room"
        session.manually_scheduled = true
        session.save!
      elsif constraints == 'delete'
        if row["Name"] != session.title
          raise "Name mismatch"
        end
        puts "    DELETING"
        session.event_id = -session.event_id.abs
        session.save!
      else
        if !presenter
          presenter = session.presenters.select { |p| p.sessions_presenting.where(event: event).count == 1 }.first
          if !presenter
            raise "Cannot choose a single presenter to attach the session-based time constraint to " +
                  "because all the presenters for this session are presenting other sessions too."
          end
          puts "    Attaching time constraints to #{presenter.name}, who is not presenting any other sessions"
        end
        constraints.split(',').map(&:strip).each do |constraint|
          puts "    #{constraint}"

          if /^#(?<ids>(\s*\d+\s*)+)$/ =~ constraint
            presenter.restrict_to_only(
              Timeslot.find(
                ids.split))
            next
          end

          unless %r{
            ^
            (?<rule>    [<>@]   )
                        \s*
            (?<hour>    \d{1,2} )
                        :
            (?<minute>  \d{2}   )
                        \s*
            (?<ampm>    [ap]m   )
            $
          }mx =~ constraint
            raise "Cannot parse constraint: #{constraint.inspect}"
          end

          hour = hour.to_i
          minute = minute.to_i
          hour = 0 if hour == 12
          hour += 12 if ampm == "pm"
          time = Time.zone.local(event.date.year, event.date.month, event.date.day, hour, minute)

          case rule
          when '<' then presenter.restrict_after(time, 1, event)
          when '>' then presenter.restrict_before(time, 1, event)
          when '@' then presenter.restrict_not_at(time, 1, event)
          end
        end
        puts "    #{presenter.name} now restricted to the following timeslots:"
        available_slots = event.timeslots.where(schedulable: true)
        available_slots -= presenter.presenter_timeslot_restrictions
          .where(timeslot: event.timeslot_ids)
          .map(&:timeslot)
        available_slots.each do |slot|
          puts "      #{slot}"
        end
      end

      puts
    end
  end

  desc 'show restrictions for current event'
  task :show_restrictions => :environment do
    restrictions_grouped = PresenterTimeslotRestriction
      .where('timeslot_id in (select id from timeslots where event_id = ?)', event.id)
      .group_by(&:participant)
    restrictions_grouped.each do |presenter, restrictions|
      puts "#{presenter.name}"
      sessions = presenter.sessions_presenting.where('event_id = ?', event.id)
      puts "  who is presenting:"
      sessions.map(&:title).each do |title|
        puts "        #{title}"
      end
      restrictions.each do |r|
        puts "  #{r.weight >= 1 ? 'cannot' : 'prefers not to'}" +
             " present at #{r.timeslot}" +
             " (weight=#{r.weight})"
      end
    end
  end

  desc 'clear the current schedule (DANGER: Irreversible!!!). You must do the before generating a new schedule'
  task clear_schedule: :environment do
    STDOUT.puts "Are you sure? This destroys the existing schedule and you will not be\n" \
      "able to retrieve it. You should back up the database before doing this.\n\nIf you are really sure, type \"SCHEDULE ARMAGEDDON\" now (anything else to cancel)..."
    input = STDIN.gets.strip
    if input == 'SCHEDULE ARMAGEDDON'
      event.sessions.update_all(timeslot_id: nil)
      STDOUT.puts "\nThe current schedule has been erased."
    else
      STDOUT.puts "\nNo changes made."
    end
  end

  # CAUTION! This task wipes and regenerates the schedule, removing any existing room & timeslot
  # assignments.
  #
  # To prevent this task from altering a particualr session's timeslot and room, use:
  #
  #   session.update_attributes(manually_scheduled: true)
  #
  desc 'Create a schedule for the current event. DANGER: Wipes existing schedule!'
  task :generate_schedule => :environment do
    quality = (ENV['quality'] || 1).to_f

    puts "Scheduling #{event.name}..."

    schedule = Scheduling::Schedule.new event
    puts
    puts schedule.inspect_bounds

    puts
    puts "Assigning sessions to time slots..."
    max_iter         = (quality ** 0.5 * 12000).ceil
    repetition_count = 1  # because generate_schedule now supports manual re-running
    puts
    puts "Quality = #{quality}:    (adjust using 'quality' env var)"
    puts "   #{repetition_count} cooling cycle(s)"
    puts "   * #{max_iter} iterations each"
    puts "   = #{repetition_count * max_iter} total iterations"
    puts

    annealer = Annealer.new(
      repetition_count: repetition_count,
      cooling_time: 100 * repetition_count,
      cooling_func: (
        lambda do |iter_count|
          Math.exp(-(iter_count + 15000) / (100 * repetition_count))
        end
      ),
      max_iter: max_iter,
      log_to: STDOUT)
    best = annealer.anneal schedule
    puts "BEST SOLUTION:"
    p best

    best.save!

    best.dump_presenter_conflicts

    puts
    puts 'Best schedule saved to DB.'
  end

  desc 'assign scheduled sessions to rooms'
  task :assign_rooms => :environment do
    Session.transaction(isolation: :serializable) do
      already_assigned_count = 0
      reassign_existing_rooms = (ENV['reassign_rooms'].to_i != 0)

      rooms_by_capacity = event.rooms.sort_by { |r| -r.capacity }
      event.timeslots.where(schedulable: true).order('starts_at').each do |slot|
        puts slot
        sessions = Session.largest_attendance_first(slot.sessions)

        unless reassign_existing_rooms
          assigned, unassigned = sessions.partition(&:room_id?)
          sessions = unassigned
          already_assigned_count += assigned.size
        end

        sessions.zip(rooms_by_capacity) do |session, room|
          if room.nil?
            raise "NOT ENOUGH ROOMS: #{session.timeslot} has #{session.timeslot.sessions.count} sessions," +
                  " but there are only #{event.rooms.count} rooms"
          end
          puts "    #{session.id} #{session.title}" +
               " (#{'%1.1f' % session.expected_attendance} est: #{session.attendances.count} raw vote(s), #{'%1.1f' % session.estimated_interest} time-scaled)" +
               " in #{room.name} (#{room.capacity})"
          session.room = room
          session.save!
        end
      end

      if already_assigned_count > 0
        puts
        puts "WARNING: #{already_assigned_count} sessions already had rooms assigned. " \
          "Use reassign_rooms=1 to redo these existing room assignements based on updated vote tallies."
      end
    end
  end

  desc 'export schedule for import to another node (for running annealer locally & exporting to heroku)'
  task :export_schedule => :environment do
    Event.transaction do
      export = {
        sessions: Hash[
          event.sessions.map do |session|
            [session.id, { slot: session.timeslot_id, room: session.room_id }]
          end.sort_by(&:first)  # by session ID, to facilitate diffs
        ]
      }
      puts JSON.pretty_generate(export)
    end
  end

  desc 'import schedule generated by app:export_schedule'
  task :import_schedule => :environment do
    export = JSON.parse(STDIN.read)
    Event.transaction do
      export['sessions'].each do |sid, opts|
        session = Session.find(sid)
        session.timeslot = (Timeslot.find(opts['slot']) if opts['slot'])
        session.room = (Room.find(opts['room']) if opts['room'])
        puts "#{session.timeslot} #{session.title} [#{session.room&.name}]"
        session.save!
      end
    end
  end

  desc 'print a summary of data that will affect the quality of the generated schedule'
  task :analyze_scheduler_input_quality => :environment do
    def frequencies(elems)
      elems.each_with_object(Hash.new(0)) do |elem, counts|
        counts[elem] += 1
      end
    end

    def frequency_dump(values)
      freqs = frequencies(values)
      max = freqs.map(&:last).max
      freqs.sort_by(&:first).each do |value, count|
        print "       %3d   %3d " % [value, count]
        print '━' * (60.0 * count / max).round
        if block_given?
          print ' '
          yield value, count
        end
        puts
      end
    end

    participant_count = event.participants.uniq.count
    vote_counts = frequencies(event.attendances.map(&:participant_id))
    multivoting_count = vote_counts.select { |_, count| count > 1 }.count
    multivoting_rate = 100.0 * multivoting_count / participant_count

    puts "Stats for #{event.name}"
    puts
    puts "#{event.sessions.count} sessions"
    puts "#{participant_count} participants who voted"
    puts "#{event.attendances.count} attendances"
    puts
    puts "The biggie:"
    puts "#{multivoting_count} participants (#{"%1.1f" % multivoting_rate}% of those voting) expressed interest in multiple sessions"
    puts
    
    puts "Distribution of number of sessions of interest"
    puts "(How many people expressed interest in n sessions?)"
    puts
    puts "  sessions | people"
    frequency_dump(vote_counts.values) do |vote_count, freq|
      if freq == 1
        participant_id = vote_counts.select { |_, count| vote_count == count }.first.first
        print "  (#{Participant.find(participant_id).name})"
      end
    end
    puts

    puts "Distribution of voting windows"
    puts "(How many sessions have been available for voting for at least n days?)"
    puts
    puts "      days | sessions"
    frequency_dump(
      event.sessions.map { |s| ((Time.now - s.created_at) / 1.day).floor })
    puts
    
    participants = event.participants.includes(:sessions_attending)
  end

  task :analyze_session_popularity => :environment do
    puts "Most popular sessions"
    puts
    puts "vot = Raw vote total"
    puts "exp = Expected attendance"
    puts "      (❗ indicates manual override of vote tally)"
    puts
    puts "Dots in leftmost columns show timeslot assignments"
    puts
    timeslots = event.timeslots.where(schedulable: true).order(:starts_at)
    puts "#{' ' * timeslots.count} vot exp  ID title                               presenters"
    puts "#{' ' * timeslots.count} --- ---  ---------------------------------------- ----------"
    Session.largest_attendance_first(event.sessions).each do |session|
      puts "%s %3d %3s%s %-40.40s %s" % [
        timeslots.map { |slot| slot.id == session.timeslot_id ? '•' : ' ' }.join,
        session.attendance_count,
        session.expected_attendance,
        session.manual_attendance_estimate? ? "❗" : " ", 
        "#{session.id} #{session.title.remove_fancy_chars}",
        session.presenters.map(&:email).join(", ")
      ]
    end
    puts

    puts "Scheduling conflicts that would upset the most people"
    puts
    pairs = Attendance.connection.select_rows("
        select a1.session_id s1,
               a2.session_id s2,
               count(*)
          from attendances a1,
               attendances a2,
               sessions s1,
               sessions s2
         where a1.participant_id = a2.participant_id
           and a1.session_id < a2.session_id
           and a1.session_id = s1.id
           and a2.session_id = s2.id
           and s1.event_id = #{event.id} -- ugh...how do binds work w/select_rows?!?
           and s2.event_id = #{event.id}
      group by s1, s2
      order by count desc
         limit 128")
    pairs.each do |s1_id, s2_id, count|
      s1, s2 = [s1_id, s2_id].map { |id| Session.find(id) }
      status = if !s1.timeslot_id || !s2.timeslot_id
        '(unscheduled)'
      elsif s1.timeslot_id == s2.timeslot_id
        'CONFLICT AS SCHEDULED'
      else
        ''
      end
      puts "  %3d  %-36.36s  +  %-36.36s  %s" % [count, s1.title.remove_fancy_chars, s2.title.remove_fancy_chars, status]
    end
  end

  desc 'Reset and hydrate the database with dummy data.'
  task :make_believe => :environment do
    require 'ffaker'
    require 'ruby-progressbar'

    puts 'Reset DB.'
    Rake::Task['db:reset'].invoke

    puts 'Create categories' 
    Category.find_or_create_defaults

    puts 'Creating event...'
    event = Event.create(name: FFaker::HipsterIpsum.words(3).join(' '), date: 1.month.from_now) 

    puts 'Creating timeslots...'
    Rake::Task['app:create_timeslots'].invoke

    puts 'Creating rooms...'
    Rake::Task['app:create_rooms'].invoke

    puts 'Creating 100 participants...'
    progress = ProgressBar.create(title: 'Participants', total: 1000)
    100.times do 
      participant = Participant.new
      participant.name = FFaker::Name.name
      participant.email = FFaker::Internet.safe_email
      participant.password = 'standard'
      participant.bio = FFaker::Lorem.paragraph if [true, false].sample
      participant.save!
      progress.increment
    end

    puts 'Creating sessions...'
    sessions_total = Room.count * Timeslot.count
    sessions_total.times do 
      session = Session.new
      session.title = FFaker::HipsterIpsum.phrase
      session.description = FFaker::HipsterIpsum.paragraph
      session.participant = Participant.order('RANDOM()').first 
      session.event = event
      session.categories << Category.order('RANDOM()').first
      session.save!

      high = Room.order('RANDOM()').first.capacity
      interest = (0..high).to_a.sample

      puts session.title
      participant_progress = ProgressBar.create(title: "  Interest: #{interest}", total: interest) 
      interest.times do 
        p = Participant.order('RANDOM()').first 
        unless session.participants.include?(p)
          a = Attendance.new
          a.session = session
          a.participant = p
          a.save!
        end
        participant_progress.increment
      end
    end

  end

private

  def event
    @event ||= if event_id = ENV['event']
      Event.find(event_id)
    else
      Event.current_event
    end
  end

end


# OPTION 2
# reg/bfast -  8:00 -  8:45
# session 0 -  8:45 -  9:30 
# -------------------------
# session 1 -  9:40 - 10:30
# session 2 - 10:40 - 11:30
# session 3 - 11:40 - 12:30
# -------------------------
# Lunch       12:40 -  1:30 
# -------------------------
# session 4    1:40 -  2:30
# session 5    2:40 -  3:30
# session 6    3:40 -  4:30 
# -------------------------
# HH           4:30 --> 
 

#
# 16 rooms
# 6 * 16 = 96
# 73 sessions  
#
#8:00 - 9:00 - Registration & Light Breakfast
#9:00 - 9:50 - Session 0 - Opening Remarks and Featured Session with David Hussman | Devjam
#10:00 - 10:50 - Session 1
#11:00 - 11:50 - Session 2
#12:00 - 12:50 - Session 3
#1:00 - 1:50 - Lunch
#2:00 - 2:50 - Session 4
#3:00 - 3:50 - Session 5
#4:00 - 4:50 - Session 6
#5:00 - 7:00 - Happy Hour

#
# OPTION 2
# reg/bfast -  8:00 -  8:45
# session 0 -  8:45 -  9:30 
# -------------------------
# session 1 -  9:40 - 10:30
# session 2 - 10:40 - 11:30
# session 3 - 11:40 - 12:30
# -------------------------
# Lunch       12:40 -  1:30 
# -------------------------
# session 4    1:40 -  2:30
# session 5    2:40 -  3:30
# session 6    3:40 -  4:30 
# -------------------------
# HH           4:30 --> 
 

# OPTION 3
# reg/bfast -  8:00 -  9:00
# session 0 -  9:00 -  9:50 
# -------------------------
# session 1 - 10:00 - 10:45
# session 2 - 10:55 - 11:40
# session 3 - 11:50 - 12:35
# -------------------------
# Lunch       12:30 -  1:30 
# -------------------------
# session 4    1:30 -  2:15
# session 5    2:25 -  3:10
# session 6    3:20 -  4:05
# -------------------------
# HH           4:05 --> 
