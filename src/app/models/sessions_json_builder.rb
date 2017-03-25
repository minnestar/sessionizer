class SessionsJsonBuilder

  def to_hash(session) 
    s = session
    { id: s.id,
      participant_id: s.participant.id,
      presenter_name: s.participant.name,
      presenter_twitter_handle: s.participant.twitter_handle,
      presenter_github_username: s.participant.github_profile_username,
      presenter_github_og_image: s.participant.github_og_image,
      presenter_bio: s.participant.bio,
      session_title: s.title,
      summary: s.summary,
      description: s.description,
      room_name: s.room_name,
      panel: s.panel,
      projector: s.projector,
      starts_at: s.starts_at,
      level_name: s.level_name,
      categories: s.categories.map(&:name),
      other_presenter_names: s.other_presenter_names,
      other_presenter_ids: s.other_presenters.map(&:id),
      attendance_count: s.attendance_count,
      created_at: s.created_at.utc,
      updated_at: s.updated_at.utc
    }
  end

  def to_json(sessions)
    require 'json'
    JSON.pretty_generate(sessions.map(&:to_h))
  end
  
end
