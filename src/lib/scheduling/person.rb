module Scheduling
  class Person
    attr_reader :id, :attending, :presenting

    def initialize(context, id)
      @attending  = SessionSet.new(context)
      @presenting = SessionSet.new(context, superset: @attending)  # Presenters don't necessarily upvote their own sessions
    end
  end
end
