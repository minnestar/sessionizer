require 'active_record/fixtures'

module Fixie
  def self.method_missing(symbol, args, &blck)
    find(symbol, args)
  end

  def self.find(table_name, identifier)
    table_name.to_s.classify.constantize.find(Fixtures.identify(identifier))
  end
end

class ActiveRecord::Base
  def self.fixie(label, attrs)
    obj = self.new
    attrs.each do |key, value|
      obj.send(:"#{key}=", value)
    end

    obj.id = Fixtures.identify(label)
    obj.save!

    obj
  end
end
