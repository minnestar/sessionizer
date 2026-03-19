class Category < ActiveRecord::Base
  has_many :categorizations
  has_many :sessions, through: :categorizations
  has_many :event_categories, dependent: :destroy
  has_many :events, through: :event_categories

  scope :active, -> { where(active: true) }
  scope :inactive, -> { where(active: false) }
  scope :legacy, -> { where(name: LEGACY_NAMES) }

  def self.ransackable_attributes(auth_object = nil)
    []
  end

  scope :default_order, -> { where(active: true).order(:default_position) }

  LEGACY_DEFAULTS = [
    { name: "Design", tagline: "Make it beautiful, make it usable.", description: "UI/visual design, design systems, prototyping, user testing, and design strategy.", default_position: 5 },
    { name: "Development", tagline: "Write code. Build things. Ship stuff.", description: "Software engineering, web development, mobile apps, DevOps, cloud infrastructure, APIs, databases, testing, and general coding topics.", default_position: 1 },
    { name: "Hardware", tagline: "Circuits, sensors, and things you can touch.", description: "Hardware engineering, IoT devices, robotics, 3D printing, embedded systems, and physical computing.", active: false, default_position: 0 },
    { name: "Startups", tagline: "From napkin sketch to funded company.", description: "Entrepreneurship, founding a company, fundraising, go-to-market strategy, scaling, exits, and the startup journey.", default_position: 2 },
    { name: "Other", tagline: "None of the above.", description: "For anything that genuinely doesn't fit the categories above.", default_position: 12 }
  ].freeze

  NEW_DEFAULTS = [
    { name: "Emerging Tech", tagline: "The tech horizon - blockchain, IoT, VR, quantum, and beyond.", description: "Blockchain, crypto, VR/AR, quantum computing, IoT, hardware, robotics, 3D printing, autonomous vehicles, smart cities, and technologies on the horizon.", default_position: 3 },
    { name: "AI/ML", long_name: "AI & Machine Learning", tagline: "Intelligent machines, practical applications, and the future of everything.", description: "Machine learning, large language models, generative AI, AI tools and workflows, responsible AI, and practical AI applications.", default_position: 4 },
    { name: "Product", long_name: "Product Management", tagline: "Great products don't build themselves.", description: "Product management, UX research, product strategy, roadmapping, and building the right thing.", default_position: 6 },
    { name: "Community", long_name: "Community & DEI", tagline: "Show up. Lift others. Make things better.", description: "Diversity, equity & inclusion, community organizing, civic engagement, sustainability, education, nonprofits, and any session focused on people - in tech and beyond.", default_position: 7 },
    { name: "Wellness", long_name: "Wellness & Personal Growth", tagline: "Be a better leader, teammate, and human.", description: "Leadership, team culture, burnout, mental health, productivity, work-life balance, people management, and personal development.", default_position: 8 },
    { name: "Careers", long_name: "Careers & Talent", tagline: "Find work. Hire people. Grow your career.", description: "Job searching, hiring, recruiting, salary negotiation, career pivots, bootcamps, resumes, and growing as a professional.", default_position: 9 },
    { name: "Marketing", long_name: "Marketing & Sales", tagline: "Build it, then make sure people know it exists.", description: "Branding, content marketing, social media strategy, SEO, PR, storytelling, sales processes, and customer acquisition.", default_position: 10 },
    { name: "Wildcard", tagline: "You know the vibe.", description: "Fun, quirky, creative, and one-of-a-kind sessions that don't fit anywhere else - crafts, hobbies, games, social hours, lightning talks, and anything that makes Minnebar, Minnebar.", default_position: 11 }
  ].freeze

  ALL_DEFAULTS = (LEGACY_DEFAULTS + NEW_DEFAULTS).freeze

  LEGACY_NAMES = LEGACY_DEFAULTS.map { |c| c[:name] }.freeze

  def legacy?
    LEGACY_NAMES.include?(name)
  end

  def display_long_name
    long_name || name
  end

  def self.find_or_create_defaults
    ALL_DEFAULTS.each do |attrs|
      category = Category.find_or_initialize_by(name: attrs[:name])
      category.assign_attributes(attrs.except(:name))
      category.save!
    end
  end

  def self.create_defaults_for_event(event)
    active.default_order.each do |category|
      event.event_categories.find_or_create_by!(category: category) do |ec|
        ec.position = category.default_position
      end
    end
  end
end
