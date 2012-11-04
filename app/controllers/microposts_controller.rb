class MicropostsController < ApplicationController

	before_filter :authenticate
	before_filter :authorize_user, :only => [:destroy]

	def create
		@micropost = current_user.microposts.build(params[:micropost])
		if @micropost.save
			redirect_to root_path
			flash[:success] = "Successfully Posted !"
		else
			@feed_items = []
			render 'pages/home' 
		end
	end

	def destroy
		@micropost.destroy
		redirect_to root_path
		flash[:success] = "Post deleted"
	end

	private

	def authorize_user
		@micropost = Micropost.find(params[:id])
		redirect_to root_path unless current_user?(@micropost.user)
	end
end