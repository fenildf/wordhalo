module WelcomeHelper
    def today_cards_count
        @user.cards.where(["schedule < ?", DateTime.tomorrow]).count
    end
    
    def total_cards_count
        @user.cards.count
    end
end
