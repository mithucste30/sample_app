class UsersController < ApplicationController

  before_filter :authenticate, :only => [:index, :edit, :update, :destroy]
  before_filter :correct_user, :only => [:edit, :update]
  before_filter :admin_user ,  :only => :destroy

  def index
    @users = User.paginate(:page => params[:page])
    @title = "All users"

  end
  
  def show
  	@user       =  User.find(params[:id])
    @microposts =  @user.microposts.paginate(:page => params[:page])
  	@title      =  @user.name
  end

  def new
  	@user  =  User.new 
  	@title = 'Sign up'
  end

  def create
  	@user  =  User.new(params[:user])
  	if @user.save
      sign_in @user
      flash[:success] = "Welcome to the Sample App!"
      redirect_to user_path(@user)
    else

      @title = 'Sign up' 
  	  render 'new'
    end
  end

  def edit
    # @user = User.find(params[:id]) this will still work bcoz we added before filter coorect_user, look up,and the correct user contailns this line, look below.so this inherits the id and other user property from that correct_user.
    @title = "Edit user"
  end

  def update
    # @user = User.find(params[:id]) this will still work bcoz we added before filter coorect_user, look up,and the correct user contailns this line, look below.so this inherits the id and other user property from that correct_user.
    if @user.update_attributes(params[:user])
      redirect_to @user
      flash[:success] = "Successfully Updated"
    else
    @title = "Edit user"
    render 'edit'
  end
  end

  def destroy
    # @user = User.find(params[:id]) this will still work bcoz we added before filter coorect_user, look up,and the correct user contailns this line, look below.so this inherits the id and other user property from that correct_user.
    @user.destroy
    flash[:success] = "User destroyed !"
    redirect_to(users_path)
  end

  private

  def authenticate
     deny_access unless signed_in?
  end

  def correct_user 
    @user = User.find(params[:id])
    redirect_to(root_path) unless @user == current_user
  end

  def deny_access
    store_location
    redirect_to signin_path, :notice => "Please Sign in to access this page"
  end

  def store_location
    session[:return_to] = request.fullpath
  end

  def admin_user
    @user = User.find(params[:id])
    redirect_to(root_path) if (!current_user.admin? || current_user?(@user))
  end

  
end
