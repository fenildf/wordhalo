class Card < ActiveRecord::Base
    belongs_to :user
    belongs_to :word
    
    def client_format
         {  id: self.id,
            study_type: self.study_type ,
            study_count: self.study_count ,
            study_trace: self.study_trace ,
            word_id: self.word_id }
    end
end
