$ ()->
    class Word
        @_dic: {}
        @get: (word_id)->
            if !(word_id of @_dic)
                @_dic[word_id] = new Word(word_id)
            @_dic[word_id]
            
        constructor: (word_id)->
            @id = word_id
            @title = null
            @pronounce = null
            @translation_chinese = null
            @sentences = null
            @download()
            @_fire_on_ready = null
            
        is_ready: ()-> @title != null
            
        download: ()->
            $.get '/api/words/get', id: @id, (data) =>
                @title = data.title
                @pronounce = data.pronounce
                @translation_chinese = data.translation_chinese
                @sentences = data.sentences
                if @_fire_on_ready != null
                    @_fire_on_ready()
        
        fire_on_ready: (callback)->
            return if callback == null
            if @is_ready()
                callback()
            else
                @_fire_on_ready = callback

    class Card
        constructor: (card_id)->
            @id = card_id
            @study_count = null
            @study_type = null
            @word = null
            @download()
            @_fire_on_ready = null
        
        is_ready: ()-> @study_type != null
        
        download: ()->
            $.get '/api/cards/get', id: @id, (data) =>
                @study_count = data.study_count
                @study_type = data.study_type
                @word = Word.get(data.word_id)
                @word.fire_on_ready(@_fire_on_ready)
        
        fire_on_ready: (callback)->
            return if callback == null
            if @is_ready() and @word.is_ready()
                callback()
            else
                @_fire_on_ready = callback
            
    card = new Card 10
    card.fire_on_ready ()-> console.log(card)
        