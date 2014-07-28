$ ()->
    new_words_count = $("#new_words_count")[0].value
    idx = 0
    $("#new_word_div_#{idx}").toggleClass("hidden")
    
    next_word = ()->
        $("#new_word_div_#{idx}").toggleClass("hidden")
        new_word_id = $("#new_word_id_#{idx}")[0].value
        word_id = $("#word_id_#{idx}")[0].value
        $.ajax "/api/new_words/delete",
            type: "delete"
            data: { id: new_word_id }
        $.post "/api/cards/add", word_id: word_id
        $.ajax "/api/user/study_new_word", type: "patch"
        
        idx += 1
        if idx < new_words_count
            $("#new_word_div_#{idx}").toggleClass("hidden")
        else
            window.location = "/user";
    
    $(".btn-next-word").click next_word
    
    KEY_CODE_F = 70
    KEY_CODE_f = 102
    $("body").keypress (e)->
      switch e.which
        when KEY_CODE_F or KEY_CODE_f then next_word()