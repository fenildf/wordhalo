$ () ->
    $word_title = $("#word_title")
    $add_button = $("#add-button")
    $added_list = $("#added-list")
    
    getWordTitle = ()->
        $word_title[0].value
    
    checkAddButtonDisable = ()->
        $add_button.prop('disabled', getWordTitle().length <= 0)
        
    $word_title.keyup (e)->
        checkAddButtonDisable()
        
    $add_button.click (e)->
        e.preventDefault()
        word_title = getWordTitle()
        $word_title[0].value = ""
        $label = $('<span class="label label-default pull-right"></span>')
        $label.html("Adding")
        $word = $('<span></span>')
        $word.html(word_title)
        $li = $('<li class="list-group-item"></li>')
        $li.append($word)
        $li.append($label)
        $added_list.prepend($li)
        $.post "/api/new_words/add",
            word_title: word_title
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
                        $label.addClass("label-warning")
                        $label.html("Not found")
                    else
                        $label.addClass("label-default")
                        $label.html("#{jqXHR.status} - #{textStatus}")
        .fail () ->
            $label.removeClass("label-default")
            $label.addClass("label-danger")
            $label.html("Failed")
    
#// <ul class="list-group">
#//   <li class="list-group-item">
#//     <span class="badge">14</span>
#//     Cras justo odio
#//   </li>
#// </ul>