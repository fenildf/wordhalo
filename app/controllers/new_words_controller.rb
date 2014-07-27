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
    
    @new_words = current_user.new_words
  end
  
  def api_add #post
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
    card = current_user.cards.find_by( word_id: word.id )
    if new_word == nil && card == nil
      current_user.new_words.create( word_id: word.id )
      render json: word #:ok
    else
      render json: word, status: 208 #:already_reported
    end
  end
  
  def api_delete #delete
    return head(401) if not signed_in? #:unauthorized
    
    id = params[:id]
    current_user.new_words.destroy(id)
    
    head(200)
  end
end
