class Ability
  include CanCan::Ability

  def initialize(user)
    can :index, [Event, Participant, Timeslot]
  end
end
