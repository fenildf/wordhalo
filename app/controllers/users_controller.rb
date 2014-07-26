require 'json'

class UsersController < ApplicationController
    def new
        @user = User.new
    end
    
    def show
        @user = User.find(params[:id])
    end
    
    def create
        @user = User.new(user_params)
        
        if @user.save
            # Handle a successful save.
            flash[:success] = "Welcome to the Sample App!"
            redirect_to @user
        else
            render 'new'
        end
    end
    
    def export
        @user = self.current_user
        
        new_words = @user.new_words.map { |new_word| new_word.word.title }
        
        render :json => { new_words: new_words }
    end
    
    private
    
    def user_params
        params.require(:user).permit(:name, :email, :password, :password_confirmation)
    end
end
