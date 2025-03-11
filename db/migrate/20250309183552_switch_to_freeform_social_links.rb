class SwitchToFreeformSocialLinks < ActiveRecord::Migration[7.1]
  def up
    execute("select * from participants").each do |result|
      # Replace existing site-specific social media columns with bio markdown
      # that mimics the previous formatting of the two supported sites

      social_items = []
      if slurped = result["github_profile_username"].presence
        social_items << "[GitHub](https://github.com/#{extract_username(slurped)})"
      end
      if cursed = result["twitter_handle"].presence
        social_items << "Twitter: @#{extract_username(cursed)}"
      end

      if social_items.any?
        bio = result["bio"]

        bio.gsub!(/\s+\Z/, '')
        bio << "\n\n**Links:**\n\n"

        bio << social_items.map do |item|
          "- #{item}"
        end.join("\n")

        # Data-updating Rails migrations must use raw SQL instead of models to
        # ensure migrations continue to work even if models change

        update(
          "update participants set bio = $1 where id = $2",
          "Update social links in bios",
          [bio, result["id"]]
        )
      end
    end

    remove_column :participants, :github_profile_username
    remove_column :participants, :github_og_url   # Seems to be 98% redundant with prev col; ignoring
    remove_column :participants, :github_og_image # Unused...except in REST API, which is itself probably unused
    remove_column :participants, :twitter_handle
  end

  def down
    raise "Migration not reversible, because it would require parsing markdown to recover links"
  end

private
  
  def extract_username(username_or_url)
    if username_or_url =~ %r{https?://(?:.*)/(\w+)}
      $1  # heck with it, last segment of URL path is probably a username…right?
    else
      username_or_url
    end
  end
end
