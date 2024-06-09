class MarkdownContent < ActiveRecord::Base
  validates :slug, presence: true
end
