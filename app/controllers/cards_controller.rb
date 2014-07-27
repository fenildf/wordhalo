class CardsController < ApplicationController
    
    def index
        return redirect_to signin_path if not signed_in?
        
        @cards = current_user.cards
    end
    
    def play
        return redirect_to signin_path if not signed_in?
    end
    
    def api_add_word #post
        return head(401) if not signed_in? #:unauthorized
        word_id = params[:word_id]
        
        card = current_user.cards.find_by( word_id: word_id )
        return render json: card, status: 208 if card != nil #208:already_reported
        
        card = current_user.cards.create do |c|
            c.schedule = DateTime::now
            c.pending = false
            c.study_count = 0
            c.study_type = :word
            c.word_id = word_id
        end
        
        return render json: card, status: 200
    end
    
    def api_new_schedule #patch
        return head(401) if not signed_in? #:unauthorized
        id = params[:id]
        schedule = params[:schedule]
        
        card = Card.find(id)
        return head(404) if card == nil
        
        card.study_count += 1
        card.schedule = case schedule
        when :today then
            1.hours.from_now
        when :future1 then
            1.days.from_now
        when :future2 then
            2.days.from_now
        when :future3 then
            3.days.from_now
        when :future7 then
            7.days.from_now
        end
        card.save
        
        render json: card
    end
    
    def api_delete #delete
        return head(401) if not signed_in? #:unauthorized
        id = params[:id]
        Card.destroy(id)
        
        head(200)
    end
end
