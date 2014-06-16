$ ->
  # ToDo一件あたりのオブジェクト
  Todo = (title, done, order, callback)->
    self = this
    self.title = ko.observable(title)
    self.done = ko.observable(done)
    self.order = order
    self.updateCallback = ko.computed  -> 
        callback(self)
        true
      return
    
    
  # ViewModel
  viewModel = ->
    self = this
    self.page_title = 'TODOS by Knockout.js'
    self.todos = ko.observableArray([])
    self.inputTitle = ko.observable("")
    self.doneTodos = ko.observable(0)
    self.markAll = ko.observable(false)
    
    self.addOne = ->
      order = self.todos.length
      newTodo = new Todo(self.inputTitle(), false, order, self.countUpdate)
      self.todos.push(newTodo)
      return
      
    self.createOnEnter = (item, event) ->
      if event.keyCode == 13 && self.inputTitle()
        # 新規のTodoオブジェクト作成 & Observerbleに入る
        self.addOne()
        #  Todo入力テキストボックスの初期化
        self.inputTitle("")
      else
        return true
      return
    
    # TODO : ボタン押しても  すぐに反応しない、templateを使っているからか?
    self.sortItems = (item, event) ->
      self.todos().sort( (left, right) ->
          retVal = if left.title() < right.title() then -1 else 1
          return retVal
        )
      return
      
    # 入力済みアイテムの編集モードon/off切り替え
    self.toggleEditMode = (item, event) ->
      $(event.target).closest('li').toggleClass('editing')
    
    self.editOnEnter = (item, event) ->
      if event.keyCode == 13 && item.title
        item.updateCallback()
        self.toggleEditMode(item, event)
      else
        return true
      return
      
    # 自身でsubscriptionsを作る
    self.markAll.subscribe((newValue) ->
        ko.utils.arrayForEach(self.todos(), (item) ->
            item.done(newValue)
            return
        )
        return
      )
    
    self.countUpdate = (item) ->
      doneArray = ko.utils.arrayFilter(self.todos(), (item) ->
        item.done()
      )
      self.doneTodos(doneArray.length)
      return true
    return
    
    self.countDoneText = (bool) ->
      cntAll = self.todos().length
      cnt = if bool then self.doneTodos() else cntAll - self.doneTodos()
      text = "<span class='count'>" + cnt.toString() + "</span>"
      text += if bool then " completed" else " remaining"
      text += if self.doneTodos() > 1 then " items" else " item"
      text
      
    self.clear = ->
      self.todos.remove (item) ->
          item.done()
      return
    return
    
  my_model = new viewModel()
  ko.applyBindings(my_model)
  
  $("#commit").click ->
    jsonData = ko.toJSON(my_model.todos)
    jsData = ko.toJS(my_model)
    # console.log(jsonData)
    # console.log(jsData)
    # console.log(jsData['todos'])
    console.log(jsonData)
    $.ajax '/create',
        type: 'POST'
        contentType: 'application/json',
        dataType: 'json',
        # data: JSON.stringify(jsonData),
        data: jsonData,
        error: (jqXHR, textStatus, errorThrown) ->
          console.log(jqXHR)
          console.log(textStatus)
          console.log(errorThrown)
          alert("error")
        success: (data, textStatus, jqXHR) ->
          alert("success")
    return

  return
