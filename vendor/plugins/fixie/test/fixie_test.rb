require 'test_helper'

class FixieTest < ActiveSupport::TestCase

  test "fixie should create a new record when given valid attributes" do
    assert_difference 'Bicycle.count' do
      Bicycle.fixie(:continental, :name => 'Schwinn Continental', :speeds => 10, :brakes => true)
    end
  end

  test "fixie should raise an exception when given invalid attributes" do
    assert_raises ActiveRecord::RecordInvalid do
      Bicycle.fixie(:borked, :name => 'borked', :speeds => -1, :brakes => '')
    end
  end

  test "records created by fixie should be retrievalbe using the records generated id" do
    fixie_bike = Bicycle.fixie(:fixie, :name => 'Fixie', :speeds => 1, :brakes => false)

    assert_equal fixie_bike, Fixie.find(:bicycles, :fixie)
    assert_equal fixie_bike, Fixie.bicycles(:fixie)
  end

  test "if a record is not found, an exception should be raised" do
    assert_raises ActiveRecord::RecordNotFound do
      Fixie.bicycles(:non_existant)
    end
  end

  test "belongs_to associations should be assigned" do
    schwinn = Manufacturer.fixie(:schwinn, :name => 'Schwinn Bicycle Company', :founded => 1895)

    paramount = Bicycle.fixie(:paramount,
                              :name => 'Paramount',
                              :speeds => 15,
                              :brakes => true,
                              :manufacturer => schwinn)

    assert_equal schwinn, paramount.manufacturer
  end
end
