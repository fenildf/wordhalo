$ () ->
    $add_button = $("#add-button")
    $added_list = $("#added-list")
    
    $.ajaxSetup headers: {
        'X-CSRF-Token': $('meta[name="csrf-token"]').attr('content')
    }
    
    
    requests = []
    request_1 = null
    request_2 = null
    request_next = ()->
        return if request_1 != null && request_2 != null
        return if requests.length <= 0
        req = requests[0]
        requests = requests[1..]
        
        word_title = req.word_title
        $word = req.$word
        $label = req.$label
        
        if request_1 == null
            request_1 = req
        else if request_2 == null
            request_2 = req
        $.post "/api/new_words/add", word_title: word_title
        .done (data, textStatus, jqXHR ) ->
            $word.html(data.title)
            $label.removeClass("label-default")
            switch jqXHR.status
                when 208
                    $label.addClass("label-info")
                    $label.html("Exists")
                when 200
                    $label.addClass("label-success")
                    $label.html("Added")
                when 404
                else
                    $label.addClass("label-default")
                    $label.html("#{jqXHR.status} - #{textStatus}")
        .fail (jqXHR, textStatus, errorThrown) ->
            $label.removeClass("label-default")
            switch jqXHR.status
                when 404
                    $label.addClass("label-warning")
                    $label.html("Not found")
                else
                    $label.addClass("label-danger")
                    $label.html(errorThrown)
        .always ()->
            if request_1 == req
                request_1 = null
            else if request_2 == req
                request_2 = null
            request_next()
    
    $add_button.click (e)->
        e.preventDefault()
        word_title = $("#word_title")[0].value
        return if word_title.length <= 0
        $("#word_title")[0].value = ""
        $label = $('<span class="label label-default pull-right"></span>')
        $label.html("Adding")
        $word = $('<span></span>')
        $word.html(word_title)
        $li = $('<li class="list-group-item"></li>')
        $li.append($word)
        $li.append($label)
        $added_list.prepend($li)
        
        req = {}
        req.word_title = word_title
        req.$label = $label
        req.$word = $word
        requests.push req
        request_next()
    
#// <ul class="list-group">
#//   <li class="list-group-item">
#//     <span class="badge">14</span>
#//     Cras justo odio
#//   </li>
#// </ul>