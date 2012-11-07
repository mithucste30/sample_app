require 'spec_helper'

describe UsersController do

render_views

  describe "get index" do

    describe "for non sign-in users" do

      it "should deny access" do
        get :index
        response.should redirect_to(signin_path)
      end
    end

    describe "for signed in users" do
      before(:each) do
        @user = test_sign_in(Factory(:user))
        Factory(:user, :email => "another@example.com") 
        Factory(:user, :email => "another@example.net")

        30.times do
          Factory(:user, :email => Factory.next(:email))
        end
        
      end

      it "should be success" do
        get :index
        response.should be_success
      end

      it "should have the right title" do
        get :index
        response.should have_selector('title', :content => "All users")
      end

      it "should have an element for each user" do
        get :index  
        User.paginate(:page => 1).each do |user|
          response.should have_selector('li', :content => user.name)
        end
      end

      it "should paginate users" do
        get :index
        response.should have_selector('div.pagination')
        response.should have_selector('span.disabled', :content => "Previous")
        response.should have_selector('a', :href => "/users?page=2",
                                           :content => "2")
        response.should have_selector('a', :href => "/users?page=2",
                                           :content => "Next")
      end

      it "should have delete links for the admin" do
        @user.toggle(:admin)
        other_user = User.all.second
        get :index
        response.should have_selector('a', :href => user_path(other_user),
                                           :content => 'delete')
      end

      it "should not have delete links for the admin" do
        other_user = User.all.second
        get :index
        response.should_not have_selector('a', :href => user_path(other_user),
                                           :content => 'delete')
      end
    end
  end

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

    it "should show the users microposts" do
      @mp1 = Factory(:micropost, :user => @user, :content => "lorem ipsum")
      @mp2 = Factory(:micropost, :user => @user, :content => "baar quax")
      get :show, :id => @user
      response.should have_selector('span.content', :content => @mp1.content)
      response.should have_selector('span.content', :content => @mp2.content)
    end

    it "should paginate the microposts" do
      35.times {Factory(:micropost, :user => @user, :content => "foo")}
      get :show, :id => @user
      response.should have_selector('div.pagination')
    end

    it "should show the count of micropost in the sidebar" do
      10.times {Factory(:micropost, :user => @user, :content => "foo")}
      get :show, :id => @user
      response.should have_selector('td.sidebar', :content => @user.microposts.count.to_s)
    end

    describe"when signed in as another user" do
      it "should be successful" do
        test_sign_in(Factory(:user, :email => Factory.next(:email)))
        get :show, :id => @user
        response.should be_success
      end
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

  describe "GET 'edit'" do
    before(:each) do
      @user = Factory(:user)
      test_sign_in(@user)
    end
    it "should be successful" do
      get :edit, :id => @user.id
      response.should be_success
    end

    it "should have the right title" do
      get :edit, :id => @user.id
      response.should have_selector("title", :content => "Edit user")
    end

    it "should have a link to change the gravatar" do
      get :edit, :id => @user.id
      response.should have_selector('a', :href => 'http://gravatar.com/emails',
                                         :content => "change")
    end
  end

  describe "PUT 'update" do

    before(:each) do
      @user = Factory(:user)
      test_sign_in(@user)
    end

    describe "failure" do
      before(:each) do
        @attr = {:name => "", :email => "", :password => "",
             :password_confirmation => ""}
      end

      it "should render the 'edit' page" do
        put :update, :id => @user, :user => @attr
        response.should render_template('edit')
      end

      it "should have the right title" do
        put :update, :id => @user, :user => @attr
        response.should have_selector('title', :content => "Edit user")
      end
    end

    describe "success" do
      before(:each) do
        @attr = {:name => "i am nobody", :email => "ghum@ghar.com", :password => "sleeping",
                 :password_confirmation => "sleeping"}
      end

      it "should change the user's attributes" do
        put :update, :id => @user, :user => @attr
        user = assigns(:user)
        @user.reload
        @user.name.should == user.name
        @user.email.should == user.email
        @user.encrypted_password.should == user.encrypted_password
      end

      it "should show a flash message" do
        put :update, :id => @user, :user => @attr
        flash[:success].should =~ /successfully updated/i
      end
    end
  end

  describe "authentication of edit/update actions" do
    before(:each) do
      @user = Factory(:user)
    end

    describe "for non-signed-in users" do

      it "should deny actions to edit" do
        get :edit, :id => @user
        response.should redirect_to(signin_path)
        flash[:notice].should =~ /please sign in/i
      end

      it "should deny actions to update" do
        put :update, :id => @user, :user => {}
        response.should redirect_to(signin_path)
      end
    end

    describe "for signed_in users" do

      before(:each) do
        wrong_user = Factory(:user, :email => "user@example.net")
        test_sign_in(wrong_user)
      end

      it "should require matching user for edit" do
        get :edit, :id => @user
        response.should redirect_to(root_path)
      end

      it "should require matching user to update" do
        put :update , :id => @user, :user => {}
        response.should redirect_to(root_path)
      end
    end
  end

  describe "DELETE 'destroy'" do

    before(:each) do
      @user = Factory(:user)
    end

    describe "for non-signed-in users" do

      it "should deny-access" do
        delete :destroy, :id => @user
        response.should redirect_to(signin_path)
      end
    end

    describe "non-admin users" do

      it "should protect the action" do
        test_sign_in(@user)
        delete :destroy, :id => @user
        response.should redirect_to(root_path)
      end
    end

    describe "as a admin user" do
      before(:each) do
        @admin = Factory(:user, :email => "admin@example.com", :admin => true )
        test_sign_in(@admin)
      end

      it "should destroy the user" do
        lambda do
          delete :destroy, :id => @user
        end.should change(User, :count).by(-1)
      end


      it "should redirect to the users(index page)" do
        delete :destroy, :id => @user
        flash[:success].should =~ /destroyed/i
        response.should redirect_to(users_path)
      end

      it "should not delete itself" do
        lambda do
          delete :destroy, :id => @admin
        end.should_not change(User, :count)
      end
    end
  end

  describe "when not signed in" do
    
    it "should not show following" do
      get :following, :id => 1
      response.should_not be_success
    end

    it "should not show followed" do
      get :followers, :id => 1
      response.should_not be_success
    end
  end

  describe "when signed in" do
    before(:each) do
      @user = test_sign_in(Factory(:user))
      @another_user = test_sign_in(Factory(:user, :email => Factory.next(:email)))
      @user.follow!(@another_user)
    end

    it "should show following" do
      get :following, :id => @user
      response.should have_selector('a', :href => user_path(@another_user),
                                                :content => @another_user.name)
    end

    it "should show followers" do
      get :followers, :id => @another_user
      response.should have_selector('a', :href => user_path(@user),
                                                :content => @user.name)
    end
  end
end
