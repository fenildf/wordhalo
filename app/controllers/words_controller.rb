require 'nokogiri'
require 'open-uri'

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
  
  def query
    word_title = params[:q]
    @word = Word.find_by(title: word_title)
    if @word == nil
      puts ">>>>>>>>>>>>> Create new word"
      @word = Word.new
      @word.version = 1
      
      url = "http://www.iciba.com/#{word_title}"
      doc = Nokogiri::HTML(open(url))
      if doc.inner_html.include? 'question unfound_tips'
        @word.version = -1
        @word.title = word_title
      else
        begin
          node = doc.css("div.title span h1").first
          @word.title = node.content
        end
        begin
          node = doc.css("div.prons span").last
          node = node.css("strong:nth-child(2)").first
          @word.pronounce = node.content
        end
        begin
          translation_chinese = {} 
          doc.css("div.group_prons div.group_pos p").each do |node|
            a1 = node.css("strong").first.content
            a2 = ""
            node.css("span label").each do |node2|
              a2 = a2 + node2.content
            end
            translation_chinese[a1] = a2
          end
          @word.translation_chinese = translation_chinese
        end
        if @word.save
          doc.css("dl.vDef_list").each do |node|
            eng = node.css("dt").first.content.strip
            translation_id = Integer(eng.split('.').first)
            @word.sentences.create(version: 1, index: translation_id, english: eng[3..-1], chinese: node.css("dd").first.content)
          end
        end
      end
    else
      # @word.sentences.each do |senctence|
      #   puts senctence.inspect
      # end
    end
    if @word.version < 0
      redirect_to root_path
    else
      redirect_to @word
    end
  end
end
