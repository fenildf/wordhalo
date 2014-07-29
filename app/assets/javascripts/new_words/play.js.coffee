$ ()->
  class RequestCounter
    constructor: ()->
      @count = 0
      @callbacks = []
      
    on_request_sent: (jqXHR)->
      @count += 1
      console.log("Push request " + @count)
      jqXHR.always ()=>
        @count -= 1
        console.log("Pop request " +@count)
        if @callbacks.length <= 0 then @_invoke()
    
    finish: (callback)->
      return if callback == null
      @callbacks.push callback
      if @count <= 0 then @_invoke()
        
    _invoke: ()->
      for callback in @callbacks
        callback()
      @callbacks = []
  
  reqCounter = new RequestCounter()
  rc = (jqXHR)-> reqCounter.on_request_sent jqXHR
  
  new_words_count = $("#new_words_count")[0].value
  next_page_path = $("#next_page_path")[0].value
  idx = -1
  
  next_word = ()->
    if idx >= 0
      $("#new_word_div_#{idx}").toggleClass("hidden")
      new_word_id = $("#new_word_id_#{idx}")[0].value
      word_id = $("#word_id_#{idx}")[0].value
      rc $.ajax "/api/new_words/delete",
          type: "delete"
          data: { id: new_word_id }
      rc $.post "/api/cards/add", word_id: word_id
      rc $.ajax "/api/user/study_new_word", type: "patch"
    
    idx += 1
    if idx < new_words_count
      $("#new_word_div_#{idx}").toggleClass("hidden")
    else
      $("#redirect-banner").removeClass("hidden")
      reqCounter.finish ()->
        console.log("Jump to: " + next_page_path)
        window.location = next_page_path
  
  $(".btn-next-word").click next_word
  
  KEY_CODE_F = 70
  KEY_CODE_f = 102
  $("body").keypress (e)->
    switch e.which
      when KEY_CODE_F, KEY_CODE_f then next_word()
      
  next_word()