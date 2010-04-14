require 'rubygems'
require 'test/unit'
require 'active_support'
require 'active_support/test_case'
require 'active_record'
require 'active_record/fixtures'


ActiveRecord::Base.establish_connection({ :adapter => 'sqlite3',
                                          :database => ':memory:' })

require 'schema'
require 'bicycle'
require 'manufacturer'

require 'fixie'

# class ActiveSupport::TestCase
#   include ActiveRecord::TestFixtures


#   fixtures :all
# end
