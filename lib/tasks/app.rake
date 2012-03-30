namespace :app do
  desc 'create default timeslots for the most recent event'
  task :create_timeslots => :environment do
    session_length = 50.minutes
    event = Event.current_event

    start_times = ["09:40",
                   "10:40",
                   "11:40",
                   "13:40",
                   "14:40",
                   "15:40",
                   "16:40"]

    start_times.each do |st|
      event.timeslots.create!(:starts_at => st) do |obj|
        obj.ends_at = obj.starts_at + 50.minutes
      end
    end
  end

  desc 'create default rooms for most recent event'
  task :create_rooms => :environment do
    event = Event.current_event

    rooms = [{ :name => 'Harriet',
               :capacity => 100 },
             { :name => 'Calhoun',
               :capacity => 100 },
             { :name => 'Nokomis',
               :capacity => 100 },
             { :name => 'Theater',
               :capacity => 250 },
             { :name => 'Proverb-Edison',
               :capacity => 60 },
             { :name => 'Emerson',
               :capacity => 40 },
             { :name => 'Learn',
               :capacity => 24 },
             { :name => 'Texas',
               :capacity => 20 }]

    rooms.each do |room|
      event.rooms.create!(room)
    end
  end
  
  desc 'create a schedule for most recent event'
  task :generate_schedule => :environment do
    quality = ENV['quality'].to_f || 1
    
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

