module CardsHelper
    def study_type_label(card)
        label_class = case card.study_type
        when "word" then "success"
        else "default" end
        sprintf('<span class="label label-%s">%s</span>', label_class, card.study_type).html_safe
    end
end
