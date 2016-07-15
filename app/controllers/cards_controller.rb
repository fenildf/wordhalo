class CardsController < ApplicationController
    
    def index
        return redirect_to signin_path if not signed_in?
        
        @cards = current_user.cards.order("schedule ASC")
    end
    
    def play
        return redirect_to signin_path if not signed_in?
    end
    
    def api_get_batch
        return head(401) if not signed_in? #:unauthorized
        
        find_results = current_user.cards.order("schedule ASC").limit(20).shuffle.take(7)
        if params[:format] == "id"
            json = find_results.map { |card| card.id }
        else
            json = find_results.map { |card| card.client_format }
        end
        render json: json
    end
    
    def api_get #get
        return head(401) if not signed_in? #:unauthorized
        
        card = current_user.cards.find(params[:id])
        return head(404) if card == nil
        
        render json: card.client_format
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
        
        card = current_user.cards.find(id)
        return head(404) if card == nil
        
        card.study_count += 1
        schedule_number = schedule.to_i
        if schedule_number == 0 then
            delay = 1.hours
        elsif schedule_number == 7 then
            delay = rand(6..8).days - 10.hours
        elsif schedule_number == 20 then
            delay = rand(18..22).days - 10.hours
        elsif schedule_number > 0 then
            delay = schedule_number.days - 10.hours
        else
            raise "Unknown schedule type: #{schedule}"
        end
        card.study_trace = schedule
        card.schedule = DateTime.now + delay
        # if card.schedule < DateTime.now
        #     card.schedule = DateTime.now + delay
        # else
        #     card.schedule = card.schedule + delay
        # end
        card.save
        
        render json: card
    end
    
    def api_delete #delete
        return head(401) if not signed_in? #:unauthorized
        id = params[:id]
        current_user.cards.destroy(id)
        
        head(200)
    end
end
