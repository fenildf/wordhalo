module WelcomeHelper
    def today_cards_count
        @user.cards.where(["DATE(created_at) < ?", Date.tomorrow]).count
    end
    
    def total_cards_count
        @user.cards.count
    end
end
