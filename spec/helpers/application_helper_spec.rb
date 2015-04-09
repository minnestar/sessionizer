require 'spec_helper'

describe ApplicationHelper do
  RSpec::Matchers.define :eq_ignoring_space do |expected|
    def normalize_space(string)
      string.
        gsub(/\s+/, ' ').        # Don't care how many spaces or what kind
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
  end
end

