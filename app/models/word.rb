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
    
    private
    def serialize_translation
        self.serialized_chinese = ActiveSupport::JSON.encode(@translation_chinese)
    end
    
    def deserialize_translation
        @translation_chinese = ActiveSupport::JSON.decode(self.serialized_chinese)
    end
end
