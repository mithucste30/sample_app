require 'spec_helper'

describe UsersController do

render_views

  describe " GET 'show" do

    before(:each) do
      @user = Factory(:user) # remember this line specially.laterly it will be needed.
    end

    it "should be successful" do
      get :show, :id => @user.id
      response.should be_success
    end

    it "should find the right user" do
      get :show,:id => @user.id
      assigns(:user).should == @user # here :user is the value at the controller>>@user. and on the right hand side @user is the value of the :user in the factory.matching that we are getting the right user.
    end

  end

  describe "GET 'new'" do
    it "should be successful" do
      get :new 
      response.should be_success
    end

    it 'should have the right title' do
    	get :new
    	response.should have_selector('title', :content => 'Sign up')
    end
  end

end
