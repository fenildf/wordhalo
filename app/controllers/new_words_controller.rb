class NewWordsController < ApplicationController

  def index
    @new_words = self.current_user.new_words
  end
  
  def add
    word_id = params[:word_id]
    
    new_word = self.current_user.new_words.find_or_create_by( word_id: word_id )
    puts "Hahahah #{new_word.inspect}"
    redirect_to root_path

  end
end
