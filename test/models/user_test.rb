require 'test_helper'

class UserTest < ActiveSupport::TestCase
  test 'valid user' do
    user = User.new(first_name: 'Jane', last_name: 'Doe', email: 'jane@example.com', username: 'janedoe',
                    password: 'password123')

    assert_predicate user, :valid?
  end

  test 'requires first_name' do
    user = User.new(last_name: 'Doe', email: 'jane@example.com', username: 'janedoe', password: 'password123')

    assert_not user.valid?
    assert_includes user.errors[:first_name], "can't be blank"
  end

  test 'requires last_name' do
    user = User.new(first_name: 'Jane', email: 'jane@example.com', username: 'janedoe', password: 'password123')

    assert_not user.valid?
    assert_includes user.errors[:last_name], "can't be blank"
  end

  test 'requires email' do
    user = User.new(first_name: 'Jane', last_name: 'Doe', username: 'janedoe', password: 'password123')

    assert_not user.valid?
    assert_includes user.errors[:email], "can't be blank"
  end

  test 'requires unique email' do
    user = User.new(first_name: 'Jane', last_name: 'Doe', email: users(:alice).email, username: 'janedoe',
                    password: 'password123')

    assert_not user.valid?
    assert_includes user.errors[:email], 'has already been taken'
  end

  test 'requires username' do
    user = User.new(first_name: 'Jane', last_name: 'Doe', email: 'jane@example.com', password: 'password123')

    assert_not user.valid?
    assert_includes user.errors[:username], "can't be blank"
  end

  test 'requires unique username' do
    user = User.new(first_name: 'Jane', last_name: 'Doe', email: 'jane@example.com', username: users(:alice).username,
                    password: 'password123')

    assert_not user.valid?
    assert_includes user.errors[:username], 'has already been taken'
  end

  test 'has many attended_events through attendances' do
    user = users(:alice)

    assert_includes user.attended_events, events(:upcoming_gala)
  end

  test 'has many followed_organizations through follows' do
    user = users(:alice)

    assert_includes user.followed_organizations, organizations(:charity_org)
  end

  test 'authenticates with correct password' do
    user = users(:alice)

    assert user.authenticate('password123')
  end
end
