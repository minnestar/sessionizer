require 'spec_helper'

describe ApplicationHelper do
  RSpec::Matchers.define :eq_ignoring_space do |expected|
    def normalize_space(string)
      string.
        gsub(/\s+/, ' ').        # Don't care how many spaces or what kind
        gsub('<p></p>', ' ').    # Markdown likes to do this sometimes
        gsub(/^ +| +$/, '').     # Ignore space at beginning & end
        gsub(/> +</, '><')       # Ignore space around tags
    end

    match do |actual|
      normalize_space(actual) == normalize_space(expected)
    end
  end

  describe "#generate_meta_description" do
    it "returns prose description with future tense, time range, and venue" do
      event = create(:event,
        name: "Minnebar 21",
        date: Date.new(2027, 5, 1),
        venue: "Best Buy HQ",
        start_time: Time.zone.local(2027, 5, 1, 8, 0),
        end_time: Time.zone.local(2027, 5, 1, 18, 30))

      expect(helper.generate_meta_description(event)).to eq(
        "Minnebar 21 is a participant-led unconference free and open to all. It'll be held on Saturday, May 1st, 2027 from 8am-6:30pm at Best Buy HQ."
      )
    end

    it "returns multi-day format with past tense" do
      event = create(:event,
        name: "Minnebar 15",
        date: Date.new(2020, 10, 6),
        start_time: Time.zone.local(2020, 10, 6, 9, 0),
        end_time: Time.zone.local(2020, 10, 17, 11, 55))

      expect(helper.generate_meta_description(event)).to eq(
        "Minnebar 15 is a participant-led unconference free and open to all. It was held Tuesday, October 6th - Saturday, October 17th, 2020 at Best Buy HQ."
      )
    end

    it "uses past tense for past events" do
      event = create(:event,
        name: "Minnebar 18",
        date: Date.new(2024, 4, 20),
        start_time: Time.zone.local(2024, 4, 20, 8, 0),
        end_time: Time.zone.local(2024, 4, 20, 19, 0))

      expect(helper.generate_meta_description(event)).to eq(
        "Minnebar 18 is a participant-led unconference free and open to all. It was held on Saturday, April 20th, 2024 from 8am-7pm at Best Buy HQ."
      )
    end

    it "falls back to date-only format when times are nil" do
      event = create(:event, name: "Minnebar 20", date: Date.new(2027, 4, 17), start_time: nil, end_time: nil)

      expect(helper.generate_meta_description(event)).to eq(
        "Minnebar 20 is a participant-led unconference free and open to all. It'll be held on Saturday, April 17th, 2027 at Best Buy HQ."
      )
    end

    it "returns the default fallback when no event exists" do
      expect(helper.generate_meta_description(nil)).to eq("Minnebar is a participant-led unconference free and open to all.")
    end

    it "defaults to using Event.current_event" do
      event = create(:event, name: "Minnebar 22", date: Date.new(2027, 6, 1))

      expect(helper.generate_meta_description).to include("Minnebar 22")
    end
  end

  describe "#markdown" do
    it 'converts markdown to html' do
      expect(helper.markdown("foo\n\n* bar\n* baz")).
        to eq_ignoring_space "<p>foo</p><ul><li>bar</li><li>baz</li></ul>"
    end

    it 'closes tags' do
      expect(helper.markdown("<strong>foo\n\nbar <i>baz")).
        to eq_ignoring_space "<p><strong>foo</strong></p><p>bar <i>baz</i></p>"
    end

    it 'sanitizes malformed tags' do
      expect(helper.markdown("foo <strong bar")).
        to eq_ignoring_space "<p>foo &lt;strong bar</p>"
    end

    it 'allows some limited html formatting' do
      html = '<p>foo <i>bar</i> and <b>baz</b><br>So <strong>there!</strong></p><ul><li>foo</li></ul>'
      expect(helper.markdown(html)).
        to eq_ignoring_space html
    end

    it 'allows links' do
      expect(helper.markdown('foo <a href="http://bar.com">bar</a> baz')).
        to eq_ignoring_space '<p>foo <a href="http://bar.com">bar</a> baz</p>'
    end

    it 'limits link attributes' do
      expect(helper.markdown('foo <a href="http://bar.com" target="_blank" onclick="alert(1)" style="font-size: 200%" class="huge">bar</a> baz')).
        to eq_ignoring_space '<p>foo <a href="http://bar.com">bar</a> baz</p>'
    end

    it 'allows img tags' do
      expect(helper.markdown('foo <img src="http://bar.com"> bar')).
        to eq_ignoring_space '<p>foo <img src="http://bar.com"> bar</p>'
    end

    it 'limits img tag attributes' do
      expect(helper.markdown('foo <img src="http://bar.com" width=100 style="border: 2px solid red" height=200 border=7 alt="bar"> bar')).
        to eq_ignoring_space '<p>foo <img src="http://bar.com" width="100" height="200" alt="bar"> bar</p>'
    end

    [:iframe, :script, :nonstandard].each do |tag|
      it "strips <#{tag}> tags" do
        expect(helper.markdown("foo <#{tag}>bar</#{tag}> baz")).
          to eq_ignoring_space "<p>foo bar baz</p>"
      end
    end
  end
end
