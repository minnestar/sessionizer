namespace :app do
  desc 'create default timeslots for the most recent event'
  task :create_timeslots => :environment do
    session_length = 45.minutes
    event = Event.current_event
    event.timeslots.destroy_all

    start_times = ["09:40",
                   "10:40",
                   "11:40",
                   "13:50",
                   "14:50",
                   "15:50",
                   "16:50"]

    start_times.each do |st|
      starts = Time.zone.parse("#{event.date.to_s} #{st}")
      event.timeslots.create!(:starts_at => starts, :ends_at => starts + session_length)
    end
  end

  desc 'create default rooms for most recent event. Will nuke old rooms.'
  task :create_rooms => :environment do
    event = Event.current_event
    event.rooms.destroy_all

    rooms = [{ :name => 'Harriet',
               :capacity => 100 },
             { :name => 'Calhoun',
               :capacity => 100 },
             { :name => 'Nokomis',
               :capacity => 100 },
             { :name => 'Minnetonka',
               :capacity => 100 },
             { :name => 'Theater',
               :capacity => 250 },
             { :name => 'Proverb-Edison',
               :capacity => 60 },
             { :name => 'Landers',
               :capacity => 40 },
             { :name => 'Learn',
               :capacity => 24 },
             { :name => 'Challenge',
               :capacity => 24 }]

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
      participant = Participant.find_by_email(ENV['EMAIL'])
    elsif ENV['PARTICIPANT']
      participant = Participant.find_by_id(ENV["PARTICIPANT"])
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
    
  
  desc 'create a schedule for most recent event'
  task :generate_schedule => :environment do
    quality = (ENV['quality'] || 1).to_f
    
    event = Event.current_event
    puts "Scheduling #{event.name}..."
    
    puts
    puts "Assigning sessions to time slots..."
    schedule = Scheduling::Schedule.new event
    annealer = Scheduling::Annealer.new :max_iter => 100000 * quality, :cooling_time => 5000000 * quality, :repetition_count => 3
    best = annealer.anneal schedule
    puts "BEST SOLUTION:"
    p best
    best.assign_rooms_and_save!
    puts
    puts 'Congratulations. You have a schedule!'
  end
end

