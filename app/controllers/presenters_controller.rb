class PresentersController < ApplicationController
  def index
    participant_ids = Session.all.map(&:participant_id)
    participants = Participant.find(participant_ids)
    csv_string = FasterCSV.generate do |csv|
      csv << ["Name", "Bio"]
      participants.each do |p|
        csv << [p.name.try(:strip), p.bio.try(:strip)]
      end
    end
    
    render :text => csv_string, :type => "text/csv"
  end
end
