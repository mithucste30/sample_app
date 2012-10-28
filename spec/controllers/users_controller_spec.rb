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

    it "should have the right title" do
      get :show, :id => @user.id
      response.should have_selector('title', :content => @user.name)
    end

    it "should have the user's name" do
      get :show, :id => @user.id
      response.should have_selector("h1", :content => @user.name)
    end

    it "should have  a profile image" do
      get :show, :id => @user.id
      response.should have_selector('h1>img', :class => "gravatar")
    end

    it "should have the right url" do
      get :show, :id => @user.id
      response.should have_selector('td>a', :content => user_path(@user),
                                            :href    => user_path(@user))
    end


  end

  describe "GET 'new'" do
    it "should be successful" do
      get :new 
      response.should be_success
    end

    it 'should have the right title' do
    	post :create, :user => @attr 
    	response.should have_selector('title', :content => 'Sign up')
    end

    it "should rener the 'view' page" do
      post :create, :user => @attr
      response.should render_template('new')
    end

    it "should not create a user" do
      lambda do
        post :create, :user => @attr
      end.should_not change(User, :count)
    end
  end

  describe 'sucess' do
    before(:each) do
      @attr = {:name => 'sample user', :email => 'someone@example.com', 
               :password => 'foobar',   :password_cofirmation => 'foobar'}
      end
    it 'should create a user' do
      lambda do
        post :create, :user => @attr
      end.should change(User, :count).by(1)
    end

    it 'should redirect to the user show page' do
      post :create, :user => @attr
      response.should redirect_to(user_path(assigns(:user)))
    end

    it 'should have a welcome message' do
      post :create, :user => @attr
      flash[:success].should =~ /welcome to the sample app/i
    end

    it "should sign the user in" do
      post :create, :user => @attr
      controller.should be_signed_in
    end
  end
end
