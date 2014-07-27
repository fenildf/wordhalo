class NewWordsController < ApplicationController

  def index
    return redirect_to signin_path if not signed_in?
    @user = self.current_user
    
  end
  
  def new
    return redirect_to signin_path if not signed_in?
    @user = self.current_user
  end
  
  def create
    return redirect_to signin_path if not signed_in?
    @user = self.current_user
  end
  
  def play
    return redirect_to signin_path if not signed_in?
  end
  
  def api_add
    return head(401) if not signed_in? #:unauthorized
    
    word_id = params[:word_id]
    word_title = params[:word_title]
    
    if word_title != nil
      word = query(word_title)
    else
      word = Word.find_by_id(word_id)
    end
    
    return head(404) if word == nil
    
    new_word = current_user.new_words.find_by( word_id: word.id )
    if new_word == nil
      new_word = current_user.new_words.create( word_id: word.id )
      render json: word #:ok
    else
      render json: word, status: 208 #:already_reported
    end
  end
end
