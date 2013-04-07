namespace :app do

  desc 'create default timeslots for the most recent event'
  task :create_timeslots => :environment do
    session_length = 40.minutes
    event = Event.current_event
    event.timeslots.destroy_all

    start_times = ["09:30",
                   "10:20",
                   "11:10",
                   "12:00",
                   "14:00",
                   "14:50",
                   "15:40"]

    start_times.each do |st|
      starts = Time.zone.parse("#{event.date.to_s} #{st}")
      event.timeslots.create!(:starts_at => starts, :ends_at => starts + session_length)
    end
  end

  desc 'create default rooms for most recent event. Will nuke old rooms.'
  task :create_rooms => :environment do
    event = Event.current_event
    event.rooms.destroy_all

    
    rooms = [
             { :name => 'Harriet', :capacity => 100 },
             { :name => 'Calhoun', :capacity => 100 },
             { :name => 'Nokomis', :capacity => 100 },
             { :name => 'Minnetonka', :capacity => 100 },
             { :name => 'Theater', :capacity => 250 },
             { :name => 'Proverb-Edison', :capacity => 60 },
             { :name => 'Learn', :capacity => 24 },
             { :name => 'Challenge', :capacity => 24 }, 
             { :name => 'Discovery', :capacity => 23 }, # Lower so smaller sessions get put in there: no video recording
             { :name => 'Tackle', :capacity => 23 }, # Lower so smaller sessions get put in there: no video recording
             { :name => 'Stephen Leacock', :capacity => 23 }, # Lower so smaller sessions get put in there: no video recording
             { :name => 'Gandhi', :capacity => 23 }, # Lower so smaller sessions get put in there: no video recording
             { :name => 'Texas', :capacity => 20 }
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

  desc 'Reset and hydrate the database with dummy data.'
  task :make_believe => :environment do
    require 'ffaker'
    require 'ruby-progressbar'

    puts 'Reset DB.'
    Rake::Task['db:reset'].invoke

    puts 'Creating event...'
    event = Event.create(name: Faker::HipsterIpsum.words(3), date: 1.month.from_now) 

    puts 'Creating timeslots...'
    Rake::Task['app:create_timeslots'].invoke

    puts 'Creating rooms...'
    Rake::Task['app:create_rooms'].invoke

    puts 'Creating 1000 participants...'
    progress = ProgressBar.create(title: 'Participants', total: 1000)
    1000.times do 
      participant = Participant.new
      participant.name = Faker::Name.name
      participant.email = Faker::Internet.email
      participant.password = 'standard'
      participant.bio = Faker::Lorem.paragraph if [true, false].sample
      participant.save!
      progress.increment
    end

    puts 'Creating sessions...'
    sessions_total = Room.count * Timeslot.count
    sessions_total.times do 
      session = Session.new
      session.title = Faker::HipsterIpsum.phrase
      session.description = Faker::HipsterIpsum.paragraph
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
