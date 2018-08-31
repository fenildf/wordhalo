$ ()->
  createSpin = ()->
    opts = {
      lines: 15, # The number of lines to draw
      length: 26, # The length of each line
      width: 11, # The line thickness
      radius: 40, # The radius of the inner circle
      corners: 1, # Corner roundness (0..1)
      rotate: 0, # The rotation offset
      direction: 1, # 1: clockwise, -1: counterclockwise
      color: '#000', # #rgb or #rrggbb or array of colors
      speed: 1, # Rounds per second
      trail: 65, # Afterglow percentage
      shadow: true, # Whether to render a shadow
      hwaccel: false, # Whether to use hardware acceleration
      className: 'spinner', # The CSS class to assign to the spinner
      zIndex: 2e9, # The z-index (defaults to 2000000000)
      top: '0px', # Top position relative to parent
      left: '0px' # Left position relative to parent
    }
    target = document.getElementById('spin-anchor');
    new Spinner(opts).spin(target)
  createSpin()
  
  randInt = (number)-> Math.floor Math.random()*number
  randItem = (array)-> if array == null or array.length <= 0 then null else array[randInt array.length]
  
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
    constructor: (json)->
      @id = json.id
      @study_count = json.study_count
      @study_type = json.study_type
      @study_trace = json.study_trace
      @word_id = json.word_id
      @word = null
      @visibleStat = 0
      @download()
      switch @study_trace
        when "0" then @study_trace_css = "label-danger"
        when "1" then @study_trace_css = "label-warning"
        when "3" then @study_trace_css = "label-primary"
        when "7" then @study_trace_css = "label-info"
        when "20" then @study_trace_css = "label-success"
        else @study_trace_css = "label-default"
    
    is_ready: ()-> @study_type != null
    
    download: ()->
      @word = Word.get(@word_id)
    
    show: ()->
      if @visibleStat == 0
        @$section_english = $("#section-english")
        @$section_chinese = $("#section-chinese")
        @$section_sentences = $("#section-sentences")
        @$question_buttons = $("#question-buttons")
        @$result_buttons = $("#result-buttons")
      
      switch @study_type
        when "word" then @showWord()
        else console.error("Unknown study_type: " + @study_type)
    
    showWord: ()->
      switch @visibleStat
        when 0 then @showWordSetup(); @showWord1()
        when 1 then @showWord2()

    showWordSetup: ()->
      @$title = $("#title")
      @$pronounce = $("#pronounce")
      @$english = $("#english")
      @$chinese = $("#chinese")
      @$study_trace = $("#study_trace")
      
      @$title.html(@word.title)
      @$pronounce.html(@word.pronounce)
      @$study_trace.html(@study_trace)
      @$study_trace.addClass(@study_trace_css)
      
      @$translations_chinese = []
      $translation_container = $("#section-chinese .panel-body")
      for k, v of @word.translation_chinese
        $c = $('<p class="hidden"><strong>' + k + '</strong>' + v + '</p>')
        $translation_container.append $c
        @$translations_chinese.push $c
        
      if @word.sentences.length > 0
        sentence = randItem @word.sentences
        @$english.html(sentence.chinese)
        @$chinese.html(sentence.english)

    showWord1: ()->
      @visibleStat = 1
      
      $("#section-loading").hide()
    
      maxRand = 1
      maxRand = 2 if @study_count > 3
      maxRand = 4 if @study_count > 5
      switch randInt maxRand
        when 0 #show english
          @$section_english.removeClass("hidden")
        when 1 #show chinese
          @$section_chinese.removeClass("hidden")
          randItem(@$translations_chinese).removeClass("hidden")
        when 2 #show english sentence
          @$section_english.removeClass("hidden")
          @$section_sentences.removeClass("hidden")
          @$english.removeClass("hidden")
        when 3 #show chinese sentence & chinese
          @$section_chinese.removeClass("hidden")
          for $translation_chinese in @$translations_chinese
            $translation_chinese.removeClass("hidden")
          @$section_sentences.removeClass("hidden")
          @$chinese.removeClass("hidden")

      @$question_buttons.removeClass("hidden")

    showWord2: ()->
      @visibleStat = 2

      @$study_trace.removeClass("hidden")
      
      @$section_english.removeClass("hidden")
      @$section_chinese.removeClass("hidden")
      for $translation_chinese in @$translations_chinese
        $translation_chinese.removeClass("hidden")
      if @word.sentences.length > 0
        @$section_sentences.removeClass("hidden")
      @$english.removeClass("hidden")
      @$chinese.removeClass("hidden")

      @$question_buttons.addClass("hidden")
      @$result_buttons.removeClass("hidden")
      
    hide: ()->
      @visibleStat = 0

      @$study_trace.addClass("hidden")
      @$study_trace.removeClass(@study_trace_css)
      
      @$section_english.addClass("hidden")
      @$section_chinese.addClass("hidden")
      @$section_sentences.addClass("hidden")

      for $translation_chinese in @$translations_chinese
        $translation_chinese.remove()
      @$translations_chinese = []
      @$english.addClass("hidden")
      @$chinese.addClass("hidden")

      @$question_buttons.addClass("hidden")
      @$result_buttons.addClass("hidden")
      
  current_card = null
  
  class CardQueue
    constructor: ()->
      @_q = []
      @_fire_on_ready = null
      
    count: ()-> @_q.length
      
    peek: ()-> if @_q.length > 0 then @_q[0] else null
    
    push_back: (card)-> @_q.push(card)
    
    pop_front: ()->
      card = @peek()
      if @count() > 0 then @_q = @_q[1..]
      card
    
    contains: (card_id)->
      for card in @_q
        if card.id == card_id then return true
      return false
    
    fire_on_ready: (callback)->
      return if callback == null
      @_fire_on_ready = callback
    
    get_first_unfinished_card: ()->
      for card, index in @_q
        if !card.word.is_ready()
          return [card, index]
      return [null, -1]
    
    download_more: ()->
      [card, index] = @get_first_unfinished_card()
      return if index < 0 || index > 4
      word = card.word
      if !word.is_ready()
        @downloading_word = word
        word.download()
        word.fire_on_ready ()=>
          if word == @downloading_word
            @download_more()
          if word == @_q[0].word
            if @_fire_on_ready != null
              @_fire_on_ready()
  
  queue = new CardQueue()
  
  class RequestCounter
    constructor: ()->
      @count = 0
      @callbacks = []
      
    on_request_sent: (jqXHR)->
      @count += 1
      #onsole.log("Push request " + @count)
      jqXHR.always ()=>
        @count -= 1
        #onsole.log("Pop request " +@count)
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
  
  next_word = ()->
    if current_card != null then current_card.hide()
    current_card = queue.pop_front()
    if current_card != null
      if current_card.word.is_ready()
        current_card.show()
      else
        $("#section-loading").show()
        current_card = null
    
    if queue.count() < 5 then update_queue()
    if queue.count() <= 0
      reqCounter.finish ()->
        window.location = "/";
    
  updating_queue = false
  shut_down = false
  update_queue = ()->
    return if updating_queue or shut_down
    updating_queue = true
    rc $.get '/api/cards/batch', format: "full", (data) =>
      if data.length <= 0
        shut_down = true
      else
        for card_json in data
          if !queue.contains(card_json.id)
            queue.push_back(new Card(card_json))
        queue.download_more()
        queue.fire_on_ready ()->
          if current_card == null
            next_word()
      updating_queue = false
  
  makeResultButtonCallback = (param)->
    return ()->
      return if current_card == null
      return if current_card.visibleStat < 2
      if param < 0
        rc $.ajax '/api/cards/delete',
          type: "delete"
          data: { id: current_card.id }
      else
        rc $.ajax '/api/cards/schedule',
          type: "post"
          data: { id: current_card.id, schedule: param }
      rc $.ajax "/api/user/study_card", type: "post"
      
      next_word()
  
  printDebugInfo = ()->
    _debugInfo = {}
    _debugInfo.cards = []
    for card in queue._q
      switch card.study_type
        when "word"
          _debugInfo.cards.push("word - " + card.word.title)
    console.log(_debugInfo)
      
  $('#btn0').click makeResultButtonCallback(0)
  $('#btn1').click makeResultButtonCallback(1)
  $('#btn2').click makeResultButtonCallback(3)
  $('#btn3').click makeResultButtonCallback(7)
  $('#btn7').click makeResultButtonCallback(20)
  $('#btnD').click makeResultButtonCallback(-1)
  $('#btnF').click ()->
    current_card.show()
    queue.download_more()
  KEY_CODE_q = 113
  KEY_CODE_w = 119
  KEY_CODE_e = 101
  KEY_CODE_a = 97
  KEY_CODE_s = 115
  KEY_CODE_d = 100
  KEY_CODE_f = 102
  KEY_CODE_Q = 81
  KEY_CODE_W = 87
  KEY_CODE_E = 69
  KEY_CODE_A = 65
  KEY_CODE_S = 83
  KEY_CODE_D = 68 
  KEY_CODE_F = 70
  KEY_CODE_DEBUG = 63 # '?'
  $("body").keypress (e)->
    switch e.which
      when KEY_CODE_Q , KEY_CODE_q then $('#btn0').click()
      when KEY_CODE_W , KEY_CODE_w then $('#btn1').click()
      when KEY_CODE_E , KEY_CODE_e then $('#btn2').click()
      when KEY_CODE_A , KEY_CODE_a then $('#btn3').click()
      when KEY_CODE_S , KEY_CODE_s then $('#btn7').click()
      when KEY_CODE_D , KEY_CODE_d then $('#btnD').click()
      when KEY_CODE_F , KEY_CODE_f then $('#btnF').click()
      when KEY_CODE_DEBUG then printDebugInfo()
      else
        console.log(e.which)
  
  update_queue()