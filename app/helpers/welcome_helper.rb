module WelcomeHelper
    def today_cards_count
        @user.cards.where(["DATE(schedule) < ?", Date.tomorrow]).count
    end
    
    def total_cards_count
        @user.cards.count
    end
end
