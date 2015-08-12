$ () ->
    $add_button = $("#add-button")
    
    $.ajaxSetup headers: {
        'X-CSRF-Token': $('meta[name="csrf-token"]').attr('content')
    }
    
    $add_button.click (e)->
        e.preventDefault()
        word_id = $("#word_id")[0].value
        
        $add_button.html "Adding"
        $add_button.attr 'disabled', 'disabled'
        $.post "/api/new_words/add",
            word_id: word_id
        .done (data, textStatus, jqXHR)->
            $add_button.removeClass "btn-primary"
            switch jqXHR.status
                when 208
                    $add_button.addClass("btn-info")
                    $add_button.html("Exists")
                when 200
                    $add_button.addClass("btn-success")
                    $add_button.html("Added")
                when 404
                    $add_button.addClass("btn-warning")
                    $add_button.html("Unkown Error")
                else
                    $add_button.addClass("btn-default")
                    $add_button.html("#{jqXHR.status} - #{textStatus}")
        .fail (jqXHR, textStatus, errorThrown)->
            $add_button.removeClass "btn-primary"
            switch jqXHR.status
                when 404
                    $add_button.addClass "btn-warning"
                    $add_button.html "Failed: Not found"
                else
                    $add_button.addClass "btn-danger"
                    $add_button.html errorThrown