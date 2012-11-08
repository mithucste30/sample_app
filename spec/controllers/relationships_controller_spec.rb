require 'spec_helper'

describe RelationshipsController do

	describe "access control" do
		describe "when not signed in" do
			it "should require login to create" do
				post :create
				response.should redirect_to(signin_path)
			end

			it "should require login to destroy" do
				delete :destroy, :id => 1
				response.should redirect_to(signin_path)
			end
		end

		describe "when signed in" do
			before(:each) do
				@user = test_sign_in(Factory(:user))
				@followed = Factory(:user, :email => Factory.next(:email))
			end

			it "should create relationship" do
				lambda do
					post :create, :relationship => { :followed_id => @followed.id }
					response.should redirect_to(user_path(@followed))
				end.should change(Relationship, :count).by(1)
			end

			it "should create relationship through ajax" do
				lambda do
					xhr :post, :create, :relationship => { :followed_id => @followed.id }
					response.should be_success
				end.should change(Relationship, :count).by(1)
			end
		end

		describe "DELETE 'destroy'" do
			before(:each) do
				@user = test_sign_in(Factory(:user))
				@followed = Factory(:user, :email => Factory.next(:email))
				@user.follow!(@followed)
				@relationship = @user.relationships.find_by_followed_id(@followed)
			end

			it "should destroy relationship" do
				lambda do
					delete :destroy, :id => @relationship
					response.should redirect_to(user_path(@followed))
				end.should change(Relationship, :count).by(-1)
			end

			it "should destroy relationship through ajax" do
				lambda do
					xhr :delete, :destroy, :id => @relationship
					response.should be_success
				end.should change(Relationship, :count).by(-1)
			end
		end
	end
end
