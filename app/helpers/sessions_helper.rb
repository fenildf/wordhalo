require 'nokogiri'
require 'open-uri'

module SessionsHelper
    def sign_in(user)
        remember_token = User.new_remember_token
        cookies.permanent[:remember_token] = remember_token
        user.update_attribute(:remember_token, User.hash(remember_token))
        self.current_user = user
    end
    
    def signed_in?
        !current_user.nil?
    end
    
    def sign_out
        self.current_user.update_attribute(:remember_token, User.hash(User.new_remember_token))
        self.current_user = nil
        cookies.delete(:remember_token)
    end
    
    def current_user=(user)
        @current_user = user
    end
    
    def current_user
        remember_token = User.hash(cookies[:remember_token])
        @current_user ||= User.find_by(remember_token: remember_token)
    end
    
    def query(word_title)
        word = Word.find_by(title: word_title)
        return word if word != nil
        
        word = Word.new
        word.version = 1
        
        puts ">>>>>>>>>>>>> Query iciba: #{word_title}"
        url = "http://www.iciba.com/#{word_title}"
        file = open(url)
        doc = Nokogiri::HTML(file)
        return nil if doc.inner_html.include? 'question unfound_tips'
        
        begin
          node = doc.css("div.title span h1").first
          word.title = node.content
        end
        
        word2 = Word.find_by(title: word.title)
        return word2 if word2 != nil
        
        begin
          node = doc.css("div.prons span").last
          node = node.css("strong:nth-child(2)").first
          word.pronounce = node.content if node != nil
        end
        begin
          translation_chinese = {} 
          doc.css("div.group_prons div.group_pos p").each do |node1|
            a1 = node1.css("strong").first.content
            a2 = ""
            node1.css("span label").each do |node2|
              a2 = a2 + node2.content
            end
            translation_chinese[a1] = a2
          end
          word.translation_chinese = translation_chinese
        end
        if word.save
          doc.css("dl.vDef_list").each do |node2|
            eng = node2.css("dt").first.content.strip
            translation_id = Integer(eng.split('.').first)
            word.sentences.create(version: 1, index: translation_id, english: eng[3..-1], chinese: node2.css("dd").first.content)
          end
        end
        
        file.close
          
        return word
    end
end
