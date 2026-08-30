class ActiveRecord::Base
  # given a hash of attributes including the ID, look up the record by ID.
  # If it does not exist, it is created with the rest of the options.
  # If it exists, it is updated with the given options.
  #
  # Raises an exception if the record is invalid to ensure seed data is loaded correctly.
  #
  # Returns the record.
  def self.create_or_update(options = {})
    id = options.delete(:id)
    record = where(id: id).first || new
    record.id = id
    record.attributes = options
    record.save!

    record
  end
end

Level.create_or_update(id: 1, name: "Beginner")
Level.create_or_update(id: 2, name: "Intermediate")
Level.create_or_update(id: 3, name: "Advanced")
Level.create_or_update(id: 4, name: "All levels")

Category.find_or_create_defaults

# For development, create an event (default categories are auto-created via after_create callback)
if Rails.env.development?
  # create default event if one doesn't exist
  unless Event.first
    event_date = 30.days.from_now.to_date
    Event.create!(
      name: "Minnebar Dev",
      date: event_date,
      start_time: event_date.in_time_zone.change(hour: 8, min: 0),
      end_time: event_date.in_time_zone.change(hour: 19, min: 0),
      venue: "Best Buy HQ"
    )
  end

  # create homepage summary content if it doesn't exist
  homepage_summary = MarkdownContent.find_or_initialize_by(slug: "homepage-summary")
  homepage_summary.name = "Homepage Summary"
  homepage_summary.markdown = <<~MARKDOWN
    ### What is Minnebar?
    Minnebar is a participant-led unconference where the tech community can share knowledge, discover new ideas, and connect. The best part? It's free and open to all who love technology!

    Learn more at [minnestar.org/minnebar](https://minnestar.org/minnebar/)

    ### How do I register?
    Presenters, [sponsors](https://minnestar.org/support-us/our-sponsors/), and [community supporters](https://minnestar.org/support-us/become-a-supporter/) get guaranteed tickets (we'll email you!). Everyone else can [snag a ticket here.](https://events.humanitix.com/minnebar20?c=sessionizer).

    ### Submit a Session
    Anyone can host a session. There's no formal approvals - if you submit it, plan to lead it. Submissions close Sun, April 19 at midnight.

    ### How long are sessions?
    Sessions are 40 minutes.

    ### What makes a great session?
    If you're passionate about a topic, others will be too! We've seen everything from software development and AI to mental health and even skincare. The best ones spark conversation, invite participation, and keep things engaging.

    ### What's off limits?
    - Sales Pitches & Ads: This is a knowledge-sharing event, not a trade show.
    - Drones: Best Buy's campus is a no-fly zone-please keep them at home.
    - AI-Generated Proposals: We're all about human connection. Sessions about AI are welcome, but should be led by you.
    - Anything that goes against our [Code of Conduct](https://minnestar.org/about-us/code-of-conduct/): We're here to learn and connect in a welcoming, respectful space.

    ### No Spectators, Only Participants
    Minnebar thrives on engagement. Whether leading or attending a session, come ready to engage, contribute, learn, and connect!

    ### Other Questions?
    Check out the [Minnebar Presenter Guide](https://minnestar.org/minnebar-presenter-guide/)
  MARKDOWN
  homepage_summary.save!
end

AdminUser.create!(email: "admin@example.com", password: "password", password_confirmation: "password") if Rails.env.development?
