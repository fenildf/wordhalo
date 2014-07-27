require 'json'

class UsersController < ApplicationController
    def new
        @user = User.new
    end
    
    def show
        @user = User.find(params[:id])
        puts @user.inspect
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
    
    def home
        return redirect_to signin_path if not signed_in?
        @user = current_user
    end
    
    def export
        return redirect_to signin_path if not signed_in?
        
        new_words = current_user.new_words.map { |new_word| new_word.word.title }
        cards = current_user.cards.map { |card| card.words.first.title }
        
        render :json => { new_words: new_words, cards: cards }
    end
    
    def api_study_new_word #patch
        return head(401) if not signed_in? #:unauthorized
        
        current_user.study_new_word_count += 1
        current_user.save
        
        head(200)
    end
    
    def api_study_card #patch
        return head(401) if not signed_in? #:unauthorized
        
        current_user.study_card_count += 1
        current_user.save
        
        head(200)
    end
    
    private
    
    def user_params
        params.require(:user).permit(:name, :email, :password, :password_confirmation)
    end
end
