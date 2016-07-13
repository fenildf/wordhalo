# require 'nokogiri'
# require 'open-uri'
require "rubygems"
require "json"
require "net/http"
require "uri"

class Word < ActiveRecord::Base
    has_many :sentences
    
    attr_accessor :translation_chinese
    
    before_save :serialize_translation
    after_find :deserialize_translation
    
    validates :title, presence: true
    
    def client_format
        {
            id: self.id,
            title: self.title,
            pronounce: self.pronounce,
            translation_chinese: @translation_chinese,
            sentences: self.sentences.map do |sentence| { english: sentence.english, chinese: sentence.chinese } end
        }
    end
    
    # def fetch_content(word_title)
    #     word_title = word_title.downcase
    #     url = URI.encode("http://www.iciba.com/#{word_title}")
    #     puts ">>>>>>>>>>>>> Query iciba: #{url}"
    #     begin
    #       file = open(url)
    #     rescue OpenURI::HTTPError => ex
    #       puts ex
    #       return nil
    #     end
    #     doc = Nokogiri::HTML(file)
    #     file.close
    #     return nil unless doc.inner_html.include? 'keyword'
        
    #     word = self
    #     begin
    #       node = doc.css("h1.keyword").first
    #       word.title = node.content
    #     end
        
    #     word2 = Word.find_by(title: word.title)
    #     return word2 if word2 != nil and word2.id != word.id
        
    #     begin
    #       node = doc.css("div.base-speak span").last
    #       word.pronounce = node.content if node != nil
    #     end
    #     begin
    #       translation_chinese = {} 
    #       doc.css("div.in-base ul.base-list.switch_part").first.xpath("li").each do |node1|
    #         a1 = node1.xpath("span").first.content
    #         a2 = node1.xpath("p").first.content.strip.delete(' ')
    #         translation_chinese[a1] = a2
    #       end
    #       word.translation_chinese = translation_chinese
    #     end
    #     if word.save
    #       word.sentences.destroy_all
    #       doc.css("div.info-article.article-tab div.article div.article-section").first.css("div.section-p").each do |node2|
    #         translation_id = node2.css("span.p-order").first.content.delete('.').strip
    #         eng = node2.css("p.p-english").first.content.strip
    #         chn = node2.css("p.p-chinese").first.content.strip
    #         word.sentences.create(version: 1, index: translation_id, english: eng, chinese: chn)
    #       end
    #     end
        
    #     return word
    # end
    
    private
    def serialize_translation
        self.serialized_chinese = ActiveSupport::JSON.encode(@translation_chinese)
    end
    
    def deserialize_translation
        @translation_chinese = ActiveSupport::JSON.decode(self.serialized_chinese)
    end
    
    def self.fetch_content(word)
        word_title = word.title.downcase
        
        uri = URI.parse("http://www.iciba.com/index.php?a=getWordMean&c=search&word=#{word_title}")
        puts ">>>>>>>>>>>>> Query iciba: #{uri.request_uri}"
  
        http = Net::HTTP.new(uri.host, uri.port)
        request = Net::HTTP::Get.new(uri.request_uri)
        response = http.request(request)
        json = JSON.parse response.body
        return nil if json["errno"] != 0
        
        json_baseInfo = json["baesInfo"]
        word.title = json_baseInfo["word_name"]
        
        word2 = Word.find_by(title: word.title)
        return word2 if word2 != nil and word2.id != word.id
        
        json_symbols = json_baseInfo["symbols"][0]
        word.pronounce = "[ " + json_symbols["ph_am"] + " ]"
        
        begin
            translation_chinese = {} 
            json_symbols["parts"].each do |item|
            translation_chinese[item["part"]] = item["means"].join ';'
            end
            word.translation_chinese = translation_chinese
        end
        
        if word.save
            word.sentences.destroy_all
            json_sentence = json["sentence"]
            json_sentence.each_with_index do |item, index|
                eng = item["Network_en"]
                chn = item["Network_cn"]
                word.sentences.create(version: 1, index: (index+1), english: eng, chinese: chn)
            end
        else
            return nil
        end
        return word
    end
end
