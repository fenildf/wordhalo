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
        
        idx += 1
        if idx < new_words_count
            $("#new_word_div_#{idx}").toggleClass("hidden")
        else
            window.location = "/user";
    
    $(".btn-next-word").click next_word
    $("body").keypress (e)->
        if e.which == 100 then next_word()