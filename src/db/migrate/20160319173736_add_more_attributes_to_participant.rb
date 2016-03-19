class AddMoreAttributesToParticipant < ActiveRecord::Migration
  def change
    add_column :participants, :github_profile_username, :string #github username
    add_column :participants, :github_og_image, :string # github avatar
    add_column :participants, :github_og_url,   :string # github user profile url
    add_column :participants, :twitter_handle,  :string
  end
end
