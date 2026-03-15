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

  describe "#default_meta_description" do
    context "when current event has venue and times (same day, future)" do
      let!(:event) do
        create(:event,
          name: "Minnebar 21",
          date: Date.new(2027, 5, 1),
          venue: "Best Buy HQ",
          start_time: Time.zone.local(2027, 5, 1, 8, 0),
          end_time: Time.zone.local(2027, 5, 1, 18, 30))
      end

      it "returns prose description with future tense, time range, and venue" do
        result = helper.default_meta_description
        expect(result).to include("Minnebar 21 is a participant-led unconference free and open to all.")
        expect(result).to include("It'll be held")
        expect(result).to include("8:00am")
        expect(result).to include("6:30pm")
        expect(result).to include("Best Buy HQ")
        expect(result).to end_with(".")
      end
    end

    context "when current event spans multiple days" do
      let!(:event) do
        create(:event,
          name: "Minnebar 15",
          date: Date.new(2020, 10, 6),
          start_time: Time.zone.local(2020, 10, 6, 9, 0),
          end_time: Time.zone.local(2020, 10, 17, 11, 55))
      end

      it "returns multi-day format with past tense" do
        result = helper.default_meta_description
        expect(result).to include("It was held")
        expect(result).to include("October 6th")
        expect(result).to include("October 17th")
        expect(result).to end_with(".")
      end
    end

    context "when event is in the past" do
      let!(:event) do
        create(:event,
          name: "Minnebar 18",
          date: Date.new(2024, 4, 20),
          start_time: Time.zone.local(2024, 4, 20, 8, 0),
          end_time: Time.zone.local(2024, 4, 20, 19, 0))
      end

      it "uses past tense" do
        result = helper.default_meta_description
        expect(result).to include("It was held")
        expect(result).not_to include("It'll be held")
      end
    end

    context "when current event has no times" do
      let!(:event) { create(:event, name: "Minnebar 20", start_time: nil, end_time: nil) }

      it "falls back to date-only format" do
        result = helper.default_meta_description
        expect(result).to include("Minnebar 20")
        expect(result).not_to include("am")
        expect(result).to end_with(".")
      end
    end

    context "when no current event exists" do
      it "returns the default fallback" do
        expect(helper.default_meta_description).to eq("Minnebar")
      end
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
