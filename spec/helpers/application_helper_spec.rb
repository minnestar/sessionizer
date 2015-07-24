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
