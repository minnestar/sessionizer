class CreateHomepageSummaryMarkdown < ActiveRecord::Migration[5.2]
  def up
    mc = MarkdownContent.new({
      name: 'Homepage Summary',
      slug: 'homepage-summary',
      markdown: <<-EOF
### How long are sessions?

Sessions can be at most **50 minutes** long. If you need extra
time, there will be empty small breakout rooms available.

### What kind of sessions are OK?

If you're interested in a topic, chances are others are
too. Types of sessions could
include **presentations** (on a programming
language, cool project, marketing, music, or anything
else), **panel
discussions**, **hackfests**,
or **meetups**.

**What's not OK?** Minnebar is not a forum for advertisements or snake oil sales.

If you've got an idea for a session and you want to run it by us, email casey@minnestar.org or support@minnestar.org.

### No Spectators, Only Participants

The first rule of Minnebar is **No Spectators, Only
Participants**. We encourage everyone to participate in
the event by presenting, hosting a discussion, or even just
participating in discussions and Q&amp;A. Come ready to engage
with your peers, share something you know, and learn something
new!

### Sessions from Past Events

All demos and sessions from past minne&#x2731; events have been imported into our [wiki](http://wiki.minnestar.org/). Take a stroll down memory lane with [MinneBar 1](http://wiki.minnestar.org/wiki/MinneBar_1) and everything in between.
EOF
    })
    mc.save!
  end

  def down
    mc = MarkdownContent.find_by_slug('homepage-summary')
    mc.destroy!
  end
end
