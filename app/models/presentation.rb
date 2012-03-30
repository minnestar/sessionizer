# A "presentation" is one person presenting at a session. If a session has three presenters, then it has three presentations.
# If you can come up with better terminology for this, I'm all for it! -PPC

class Presentation < ActiveRecord::Base
  belongs_to :session
  belongs_to :participant
end
