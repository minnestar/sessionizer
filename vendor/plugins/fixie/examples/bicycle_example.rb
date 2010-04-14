# This example shows how to use Fixie a couple of different ways.
# There are two models here. Manufacturer has many Bicycles, but the
# association is not required. See the fixie/test directory for the
# models.

# Create a Bicycle, not used elsewhere in this file:
Bicycle.fixie(:track, :name => 'Track Bike', :speeds => 1, :brakes => false)

# Create a Bicycle and assign it to a variable for use later:
single_speed = Bicycle.fixie(:single_speed, :name => 'Single Speed', :speeds => 1, :brakes => true)

# Create a Bicycle and then add it to a manufacturer:
trek = Manufacturer.fixie(:trek, :name => 'Trek Bicycle Corporation', :founded => 1975)
trek.bicycles << Bicyle.fixie(:one_point_two, :name => '1.2', :speeds => 27, :brakes => true)

# Or, if you don't plan on grabbing the associated object in your
# tests you can just create it with ActiveRecord:
trek.bicycles.create!(:name => '1.5', :speeds => '27', :brakes => true)

# Create a Manufacturer and then create a Bicycle using the Manufacturer.
schwinn = Manufacturer.fixie(:schwinn, :name => 'Schwinn Bicycle Company', :founded => 1895)

Bicycle.fixie(:continental, :name => 'Continental', :speeds => 10, :brakes => true, :manufacturer => schwinn)

# But watch out! Fixie will blow up if you insert invalid data -- this ensures your tests have valid data.

# invalid: record identifier already used -- results in a duplicate primary key
Bicycle.fixie(:continental, :name => 'Continental', :speeds => 10, :brakes => true, :manufacturer => schwinn)

# invalid: doesn't have a the required 'brake' attribute
Bicycle.fixie(:paramount, :name => 'Paramount', :speeds => 15)

# invalid: name is not unique
Bicycle.fixie(:paramount2, :name => 'Paramount', :speeds => 15, :brakes => true)

# and so on...
