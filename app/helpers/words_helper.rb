module WordsHelper
    def add_to_new_word
        _url = "/new_words/add?id=" + @word.id.to_s
        return `<a href="#{_url}">( ADD )</a>`
    end
end
