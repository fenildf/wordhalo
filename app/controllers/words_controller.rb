class WordsController < ApplicationController
  def index
  end
  
  def show
    @word = Word.find(params[:id])
  end

  def new
  end

  def edit
  end
  
  def search
    word_title = params[:q]
    @word = query(word_title)
    if @word.version < 0
      redirect_to root_path
    else
      redirect_to @word
    end
  end
end
