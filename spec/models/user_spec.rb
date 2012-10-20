# == Schema Information
#
# Table name: users
#
#  id         :integer          not null, primary key
#  name       :string(255)
#  email      :string(255)
#  created_at :datetime
#  updated_at :datetime
#

require 'spec_helper'

describe User do

	before (:each) do
		@attr = {:name => "Example User", :email => "user@example.com"}
	end
  
  it "should create a new instance given a valid attribute" do
  	User.create!(@attr)
  end

  it "should require a name" do
  	no_name_user = User.new(@attr.merge(:name => ""))
  	no_name_user.should_not be_valid
  end

  it "should require a name" do
  	no_email_user = User.new(@attr.merge(:email => ""))
  	no_email_user.should_not be_valid
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

end