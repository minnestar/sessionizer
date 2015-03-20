module SessionsHelper 
  
  def attending_class(session)
    (current_participant && current_participant.attending_session?(session)) ? 'attending' : 'not_attending'
  end

end
