class Word < ActiveRecord::Base
    has_many :sentences
    
    attr_accessor :translation_chinese
    
    before_save :serialize_translation
    after_find :deserialize_translation
    
    validates :title, presence: true
    
    private
    def serialize_translation
        self.serialized_chinese = ActiveSupport::JSON.encode(@translation_chinese)
    end
    
    def deserialize_translation
        @translation_chinese = ActiveSupport::JSON.decode(self.serialized_chinese)
    end
end
