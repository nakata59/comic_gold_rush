class UsersController < ApplicationController
    def new
        @user = User.new
      end
        
          def index
            if params[:keyword].present?
              #@users = User.where(name: params[:keyword])
              keyword = params[:keyword].downcase
              @users = User.where("LOWER(name) LIKE ?", "%#{keyword}%")
            end
          end
        
          def show
           @user = User.find(params[:id])
          end
        
          def create
            @user = User.new(user_params)
            if @user.save
              redirect_to login_path
            else
              render :new
            end
          end
        
          private
        
          def user_params
            params.require(:user).permit(:email, :password, :password_confirmation, :name)
          end
end
