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
        word_title = word_title.downcase
        word = Word.find_by(title: word_title)
        return word if word != nil
        
        word = Word.new
        word.version = 1
        
        puts ">>>>>>>>>>>>> Query iciba: #{word_title}"
        url = URI.encode("http://www.iciba.com/#{word_title}")
        puts url
        begin
          file = open(url)
        rescue OpenURI::HTTPError => ex
          puts ex
          return nil
        end
        doc = Nokogiri::HTML(file)
        return nil unless doc.inner_html.include? 'keyword'
        
        begin
          node = doc.css("h1.keyword").first
          word.title = node.content
          puts word.title
        end
        
        word2 = Word.find_by(title: word.title)
        return word2 if word2 != nil
        
        begin
          node = doc.css("div.base-speak span").last
          #node = node.css("strong:nth-child(2)").first
          word.pronounce = node.content if node != nil
        end
        begin
          translation_chinese = {} 
          doc.css("div.in-base ul.base-list.switch_part").first.xpath("li").each do |node1|
            a1 = node1.xpath("span").first.content
            a2 = node1.xpath("p").first.content.strip.delete(' ')
            translation_chinese[a1] = a2
          end
          word.translation_chinese = translation_chinese
        end
        if word.save
          doc.css("div.info-article.article-tab div.article div.article-section").first.css("div.section-p").each do |node2|
            translation_id = node2.css("span.p-order").first.content.delete('.').strip
            eng = node2.css("p.p-english").first.content.strip
            chn = node2.css("p.p-chinese").first.content.strip
            word.sentences.create(version: 1, index: translation_id, english: eng, chinese: chn)
          end
        end
        
        file.close
          
          puts word
        return word
    end
end
