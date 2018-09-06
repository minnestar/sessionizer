# == Schema Information
#
# Table name: presentations
#
#  id             :integer          not null, primary key
#  session_id     :integer
#  participant_id :integer
#  created_at     :datetime
#  updated_at     :datetime
#

# A "presentation" is one person presenting at a session. If a session has three presenters, then it has three presentations.
# If you can come up with better terminology for this, I'm all for it! -PPC

class Presentation < ActiveRecord::Base
  belongs_to :session
  belongs_to :participant

  validates_presence_of :session_id
  validates_presence_of :participant_id

end
