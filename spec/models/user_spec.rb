# == Schema Information
#
# Table name: users
#
#  id                 :integer          not null, primary key
#  name               :string(255)
#  email              :string(255)
#  created_at         :datetime
#  updated_at         :datetime
#  encrypted_password :string(255)
#  salt               :string(255)
#  admin              :boolean          default(FALSE)
#

require 'spec_helper'

describe User do

	before (:each) do
		@attr = {
              :name => "Example User", 
              :email => "user@example.com",
              :password => "foobar",
              :password_confirmation => "foobar"
            }
	end
  
  it "should create a new instance given a valid attribute" do
  	User.create!(@attr)
  end

  it "should require a name" do
  	no_name_user = User.new(@attr.merge(:name => ""))
  	no_name_user.should_not be_valid
  end


  it "name length must be under 50" do
  	long_name = "a" * 51
  	long_name_user = User.new(@attr.merge(:name => long_name))
  	long_name_user.should_not be_valid
  end

  it "should accept valid email addresses" do
    addresses = %w[user@info.com THE_USER@foo.bar.org first.last@foo.jp]
    addresses.each do |address|
      valid_email_user = User.new(@attr.merge(:email => address))
      valid_email_user.should be_valid
    end
  end

  it "should not accept invalid email address" do
    addresses = %w[user.email.com user.email@ user@ @user.com @user,com sample@foo,com question@answer. someone]
    addresses.each do |address|
      invalid_email_user = User.new(@attr.merge(:email => address))
      invalid_email_user.should_not be_valid
    end
  end

  it "should reject duplicate email address" do
    User.create!(@attr)
    user_with_duplicate_email = User.new(@attr)
    user_with_duplicate_email.should_not be_valid
  end

  it "should reject duplicate email upto case " do
    upscaled_email = @attr[:email].upcase
    User.create!(@attr.merge(:email => upscaled_email))
    user_with_duplicate_email_in_case = User.new(@attr)
    user_with_duplicate_email_in_case.should_not be_valid
  end

  describe "passwords" do

    before(:each) do
      @user = User.new(@attr)
    end


    it "should have a password attribute" do
      @user.should respond_to(:password)
    end

    it "should have a password confirmation attribute" do
      @user.should respond_to(:password_confirmation)
    end
  end

  describe "password validations" do

    it "should require a password" do
      User.new(@attr.merge(:password => "", :password_confirmation => "")).
              should_not be_valid
    end

    it "should require a matching password confirmaton" do
      User.new(@attr.merge(:password_confirmation => "invalid")).
              should_not be_valid
    end

    it "should reject short password" do
      short = "a" * 5
      hash  = User.new(@attr.merge(:password => short, :password_confirmation => short)).
              should_not be_valid
    end

    it "should reject long password" do
      long = "a" * 41
      hash  = User.new(@attr.merge(:password => long, :password_confirmation => long)).
              should_not be_valid
    end
  end

  describe "password encryption" do

    before(:each) do
      @user = User.create!(@attr)
    end
    it "require a encrypted password" do
      @user.should respond_to(:encrypted_password)
    end

    it "should set a encrypted password" do
      @user.encrypted_password.should_not be_blank
    end

    it "should have a salt" do
      @user.should respond_to(:salt)
    end

    describe "has password? method" do

      it "should exsist" do
        @user.should respond_to(:has_password?)
      end

      it "should return true if the password match" do
        @user.has_password?(@attr[:password]).should be_true
      end

      it "should return false if the password does not match" do
        @user.has_password?("invalid").should be_false
      end
    end

    describe "authenticate method" do

      it "should exsist" do
        User.should respond_to(:authenticate)
      end

      it "should return nil on email/password mismatch" do
        User.authenticate(@attr[:email], "wrongpass").should be_nil
      end

      it "should return nil for an email address with no user" do
        User.authenticate("bar@foo.com", @attr[:password]).should be_nil
      end

      it "should should return the user on valid username-password" do
        User.authenticate(@attr[:email], @attr[:password]).should == @user
      end
    end
  end

  describe "admin attribute" do
    before(:each) do
      @user = User.create!(@attr)
    end

    it "should respond_to admin" do
      @user.should respond_to(:admin)
    end

    it "should not be an admin by default" do
      @user.should_not be_admin
    end

    it "should be convertible to admin" do
      @user.toggle(:admin)
      @user.should be_admin
    end
  end

  describe "micropost associations" do

    before(:each) do
      @user = User.create!(@attr)
      @mp1 = Factory(:micropost, :user => @user, :created_at => 1.day.ago)
      @mp2 = Factory(:micropost, :user => @user, :created_at => 1.hour.ago)
    end

    it "should have a micropost attribute" do
      @user.should respond_to(:microposts)
    end

    it "should have the right micropost in the right order" do
      @user.microposts.should == [@mp2, @mp1]
    end

    it "should delete the associative microposts" do
      @user.destroy
      # [@mp1, @mp2].each do |micropost|
        Micropost.find_by_id(@mp1.id).should be_nil
        Micropost.find_by_id(@mp2.id).should be_nil
      # end
    end

    describe "status feed" do

      it "should have a feed" do
        @user.should respond_to(:feed)
      end

      it "should include users microposts" do
        @user.feed.should include(@mp1)
        @user.feed.should include(@mp2)
      end

      it "should not contain other user's microposts" do
        mp3 = Factory(:micropost, 
                       :user => Factory(:user, :email => Factory.next(:email)))
        @user.feed.should_not include(mp3)
      end
    end  
  end

  describe "relationships" do
    before(:each) do
      @user = User.create!(@attr)
      @followed = Factory(:user)
    end

    it "should have a relationship method" do
      @user.should respond_to(:relationships)
    end

    it "should have a following method" do
      @user.should respond_to(:following)
    end

    it "should follow a user" do # why a user have to follow someone???right??if a user doesn't follow anyone then how can we test this??
      @user.follow!(@followed)  # by writting this line we are making a user to follow :D.so by writing this line we are making a relationship.so watch in the user.rb file.we are making this line true by writng such that creates a relationship. relationship.create!(followed_id).why followed id?? coz here in this line @user is the follower.so we already a follower.all we need is a followed id.
      @user.should be_following(@followed)
    end

    it "should include the followed user in the following array" do
      @user.follow!(@followed)
      @user.following.should include(@followed)
    end

    it "should have an unfollow! method" do
      @user.should respond_to(:unfollow!)
    end

    it "should unfollow a user" do
      @user.follow!(@followed)
      @user.unfollow!(@followed)
      @user.should_not be_following(@followed)
    end

    it "should have a reverse_relationships" do
      @user.should respond_to(:reverse_relationships)
    end

    it "should have a follower method" do
      @user.should respond_to(:follower)
    end

    it "should include follower in the follower array" do
      @user.follow!(@followed)
      @followed.followers.should include(@user)
    end
  end
end
