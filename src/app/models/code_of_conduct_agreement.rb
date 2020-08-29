class CodeOfConductAgreement < ActiveRecord::Base
  belongs_to :participant
  belongs_to :event
end
