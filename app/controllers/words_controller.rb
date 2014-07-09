require 'nokogiri'
require 'open-uri'

class WordsController < ApplicationController
  def index
  end
  
  def show
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
      @word.title = word_title
      
      url = "http://www.iciba.com/#{word_title}"
      doc = Nokogiri::HTML(open(url))
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
      begin
        doc.css("dl.vDef_list").each do |node|
          eng = node.css("dt").first.content.strip
          translation_id = Integer(eng.split('.').first)
          puts translation_id
          puts eng[3..-1]
          puts node.css("dd").first.content
        end
      end
    end
    puts "--------------------------------"
    puts @word.inspect
    puts @word.translation_chinese.inspect
    puts "--------------------------------"
    redirect_to root_path
  end
end
