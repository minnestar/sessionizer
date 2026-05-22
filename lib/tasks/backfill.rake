namespace :backfill do

  desc 'backfill coc_agreed_at for participants who have already accepted'
  task coc_agreed_at: :environment do
    ActiveRecord::Base.connection.execute(<<~SQL)
      UPDATE participants
      SET coc_agreed_at = coc.created_at
      FROM (
        SELECT DISTINCT ON (participant_id) participant_id, created_at
        FROM code_of_conduct_agreements
      ) AS coc
      WHERE participants.id = coc.participant_id
      AND participants.coc_agreed_at IS NULL
    SQL
  end
end