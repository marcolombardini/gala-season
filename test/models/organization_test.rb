require 'test_helper'

class OrganizationTest < ActiveSupport::TestCase
  test 'valid organization' do
    org = Organization.new(name: 'Test Org', email: 'test@org.com', password: 'password123')

    assert_predicate org, :valid?
  end

  test 'requires name' do
    org = Organization.new(email: 'test@org.com', password: 'password123')

    assert_not org.valid?
    assert_includes org.errors[:name], "can't be blank"
  end

  test 'requires email' do
    org = Organization.new(name: 'Test Org', password: 'password123')

    assert_not org.valid?
    assert_includes org.errors[:email], "can't be blank"
  end

  test 'requires unique email' do
    org = Organization.new(name: 'Another Org', email: organizations(:charity_org).email, password: 'password123')

    assert_not org.valid?
    assert_includes org.errors[:email], 'has already been taken'
  end

  test 'validates email format' do
    org = Organization.new(name: 'Test Org', email: 'not-an-email', password: 'password123')

    assert_not org.valid?
    assert_includes org.errors[:email], 'is invalid'
  end

  test 'auto-generates slug from name' do
    org = Organization.create!(name: 'My Great Org', email: 'great@org.com', password: 'password123')

    assert_equal 'my-great-org', org.slug
  end

  test 'handles slug collisions' do
    Organization.create!(name: 'Nashville Charity Foundation', email: 'dupe@org.com', password: 'password123',
                         slug: 'nashville-charity-foundation-1')
    org = Organization.create!(name: 'Nashville Charity Foundation', email: 'dupe2@org.com', password: 'password123')

    assert_equal 'nashville-charity-foundation-2', org.slug
  end

  test 'has many events' do
    org = organizations(:charity_org)

    assert_includes org.events, events(:upcoming_gala)
  end

  test 'has many followers through follows' do
    org = organizations(:charity_org)

    assert_includes org.followers, users(:alice)
  end

  test 'authenticates with correct password' do
    org = organizations(:charity_org)

    assert org.authenticate('password123')
  end

  test 'rejects incorrect password' do
    org = organizations(:charity_org)

    assert_not org.authenticate('wrong')
  end
end
