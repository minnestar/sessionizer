namespace :app do

  desc 'create default timeslots for the most recent event'
  task create_timeslots: :environment do
    session_length = 45.minutes
    event = Event.current_event
    event.timeslots.destroy_all

    start_times = ["09:00",
                   "09:55",
                   "10:50",
                   "11:45",

                   "13:45",
                   "14:40",
                   "15:35" ]

    start_times.each_with_index do |st, idx|
      starts = Time.zone.parse("#{event.date.to_s} #{st}")
      event.timeslots.create!(
        title: "Session #{idx + 1}",
        starts_at: starts,
        ends_at: starts + session_length,
        schedulable: true
      )
    end

    event.timeslots.create!(
      title: "Lunch",
      starts_at: Time.zone.parse("#{event.date.to_s} 12:15:00"),
      ends_at: Time.zone.parse("#{event.date.to_s} 1:35:00"),
      schedulable: false
    )

    event.timeslots.create!(
      title: "Arrive/Breakfast",
      starts_at: Time.zone.parse("#{event.date.to_s} 8:00:00"),
      ends_at: Time.zone.parse("#{event.date.to_s} 8:35:00"),
      schedulable: false
    )

    event.timeslots.create!(
      title: "Session 0",
      starts_at: Time.zone.parse("#{event.date.to_s} 8:35:00"),
      ends_at: Time.zone.parse("#{event.date.to_s} 8:55:00"),
      schedulable: false
    )

    event.timeslots.create!(
      title: "Beer Me!",
      starts_at: Time.zone.parse("#{event.date.to_s} 16:45:00"),
      ends_at: Time.zone.parse("#{event.date.to_s} 19:00:00"),
      schedulable: false
    )
  end

  desc 'create default rooms for most recent event. Will nuke old rooms.'
  task :create_rooms => :environment do
    event = Event.current_event
    event.rooms.destroy_all

    rooms = [
      { name: 'Theater',         capacity: 250 },
      { name: 'Nokomis',         capacity: 100 },
      { name: 'Minnetonka',      capacity: 100 },
      { name: 'Harriet',         capacity: 100 },
      { name: 'Calhoun',         capacity: 100 },
      # { name: 'Brand',           capacity: 75 },
      { name: 'Proverb-Edison',  capacity: 48 },
      { name: 'Zeke Landres',    capacity: 40 },
      { name: 'Learn',           capacity: 24 },
      { name: 'Challenge',       capacity: 24 }, 
      { name: 'Discovery',       capacity: 23 }, # Lower so smaller sessions get put in there: no video recording
      { name: 'Tackle',          capacity: 23 }, # Lower so smaller sessions get put in there: no video recording
      { name: 'Stephen Leacock', capacity: 23 }, # Lower so smaller sessions get put in there: no video recording
      { name: 'Gandhi',          capacity: 23 }, # Lower so smaller sessions get put in there: no video recording
      { name: 'Louis Pasteur',   capacity: 18 }, 
      { name: 'Texas',           capacity: 16 }, 
      # { name: 'California',      capacity: 16 },
      { name: 'Florida',         capacity: 12 }, # TV, no projector
      { name: 'George',          capacity: 12 }, # TV, no projector
      { name: 'Kansas',          capacity: 10 }, # TV, no projector
    ]

    rooms.each do |room|
      event.rooms.create!(room)
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

  desc "restrict a presenter's timeslots"
  task :restrict => :environment do
    unless ENV['PARTICIPANT'] && ENV['HOUR']
      STDERR.puts 'Usage examples:

        Prevent participant id 577 from presenting in the afternoon:
        
           heroku run PARTICIPANT=345 HOUR=12:30 AFTER=1 rake app:restrict
        
        Create soft preference for participant id 678 not to present first thing:
        
           heroku run PARTICIPANT=678 HOUR=9:45 BEFORE=1 WEIGHT=0.1 rake app:restrict
        '
    end

    d = Event.current_event.date
    hour = ENV["HOUR"].split(':')
    time = Time.zone.local(d.year, d.month, d.day, hour[0], hour[1])
    presenter = Participant.find(ENV['PARTICIPANT'])

    weight = ENV['WEIGHT'] || 1

    if ENV['BEFORE']
      presenter.restrict_before(time, weight)
    else
      presenter.restrict_after(time, weight)
    end
  end

  desc 'show restrictions for current event'
  task :show_restrictions => :environment do
    PresenterTimeslotRestriction.all.each do |r|
      next unless r.timeslot.event == Event.current_event
      puts "#{r.participant.name}" +
           " #{r.weight >= 1 ? 'cannot' : 'prefers not to'}" +
           " present at #{r.timeslot.starts_at.in_time_zone.to_s(:usahhmm) if r.timeslot}" +
           " (weight=#{r.weight}); actual times: #{r.participant.sessions_presenting.map { |s| s.timeslot.starts_at.in_time_zone.to_s(:usahhmm)}}"
    end
  end

  desc 'clear the current schedule (DANGER: Irreversible!!!). You must do the before generating a new schedule'
  task clear_schedule: :environment do
    STDOUT.puts "Are you sure? This destroys the existing schedule and you will not be\n" \
      "able to retrieve it. You should back up the database before doing this.\n\nIf you are really sure, type \"SCHEDULE ARMAGEDDON\" now (anything else to cancel)..."
    input = STDIN.gets.strip
    if input == 'SCHEDULE ARMAGEDDON'
      Event.current_event.sessions.update_all(timeslot_id: nil)
      STDOUT.puts "\nThe current schedule has been erased."
    else
      STDOUT.puts "\nNo changes made."
    end
  end

  # We can schedule certain sessions into blocks before running
  # the scheduler. These sessions will not get scheduled elsewhere.
  # However the scheduler will pay no-attention to them, so you probably
  # only want to place them into Timeslots where schedulable is false.
  # For example you may place a "Presenters Luncheon, rm 123" during the
  # "Lunch" timeslot.
  desc 'create a schedule for most recent event. Only unassigned sessions will be scheduled.'
  task :generate_schedule => :environment do
    quality = (ENV['quality'] || 1).to_f

    event = Event.current_event
    puts "Scheduling #{event.name}..."

    schedule = Scheduling::Schedule.new event
    puts
    puts schedule.inspect_bounds

    puts
    puts "Assigning sessions to time slots..."
    max_iter         = ((quality ** 0.5) * 2000).ceil
    repetition_count =  (quality ** 0.5).ceil
    puts
    puts "Quality = #{quality}:    (adjust using 'quality' env var)"
    puts "   #{repetition_count} cooling cycle(s)"
    puts "   * #{max_iter} iterations each"
    puts "   = #{repetition_count * max_iter} total iterations"
    puts

    annealer = Annealer.new(
      repetition_count: repetition_count,
      cooling_time: 100 * repetition_count,
      max_iter: max_iter,
      log_to: STDOUT)
    best = annealer.anneal schedule
    puts "BEST SOLUTION:"
    p best

    best.assign_rooms_and_save!

    puts
    puts 'Congratulations. You have a schedule!'
  end

  desc 'export schedule for import to another node (for running annealer locally & exporting to heroku)'
  task :export_schedule => :environment do
    Event.transaction do
      export = {
        sessions: Hash[
          Event.current_event.sessions.map do |session|
            [session.id, { slot: session.timeslot.id, room: session.room.id }]
          end
        ]
      }
      puts export.to_json
    end
  end

  desc 'import schedule generated by app:export_schedule'
  task :import_schedule => :environment do
    export = JSON.parse(STDIN.read)
    Event.transaction do
      export['sessions'].each do |sid, opts|
        session = Session.find(sid)
        session.timeslot = Timeslot.find(opts['slot'])
        session.room = Room.find(opts['room'])
        puts "#{session.timeslot} #{session.title} [#{session.room.name}]"
        session.save!
      end
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
      participant.twitter_handle = FFaker::Internet.user_name(participant.name) if [true, false].sample
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
