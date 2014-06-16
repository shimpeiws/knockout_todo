(function() {
  $(function() {
    var Todo, my_model, viewModel;
    Todo = function(title, done, order, callback) {
      var self;
      self = this;
      self.title = ko.observable(title);
      self.done = ko.observable(done);
      self.order = order;
      self.updateCallback = ko.computed(function() {
        callback(self);
        return true;
      });
    };
    viewModel = function() {
      var self;
      self = this;
      self.page_title = 'TODOS by Knockout.js';
      self.todos = ko.observableArray([]);
      self.inputTitle = ko.observable("");
      self.doneTodos = ko.observable(0);
      self.markAll = ko.observable(false);
      self.addOne = function() {
        var newTodo, order;
        order = self.todos.length;
        newTodo = new Todo(self.inputTitle(), false, order, self.countUpdate);
        self.todos.push(newTodo);
      };
      self.createOnEnter = function(item, event) {
        if (event.keyCode === 13 && self.inputTitle()) {
          self.addOne();
          self.inputTitle("");
        } else {
          return true;
        }
      };
      self.sortItems = function(item, event) {
        self.todos().sort(function(left, right) {
          var retVal;
          retVal = left.title() < right.title() ? -1 : 1;
          return retVal;
        });
      };
      self.toggleEditMode = function(item, event) {
        return $(event.target).closest('li').toggleClass('editing');
      };
      self.editOnEnter = function(item, event) {
        if (event.keyCode === 13 && item.title) {
          item.updateCallback();
          self.toggleEditMode(item, event);
        } else {
          return true;
        }
      };
      self.markAll.subscribe(function(newValue) {
        ko.utils.arrayForEach(self.todos(), function(item) {
          item.done(newValue);
        });
      });
      self.countUpdate = function(item) {
        var doneArray;
        doneArray = ko.utils.arrayFilter(self.todos(), function(item) {
          return item.done();
        });
        self.doneTodos(doneArray.length);
        return true;
      };
      return;
      self.countDoneText = function(bool) {
        var cnt, cntAll, text;
        cntAll = self.todos().length;
        cnt = bool ? self.doneTodos() : cntAll - self.doneTodos();
        text = "<span class='count'>" + cnt.toString() + "</span>";
        text += bool ? " completed" : " remaining";
        text += self.doneTodos() > 1 ? " items" : " item";
        return text;
      };
      self.clear = function() {
        self.todos.remove(function(item) {
          return item.done();
        });
      };
    };
    my_model = new viewModel();
    ko.applyBindings(my_model);
    $("#commit").click(function() {
      var jsData, jsonData;
      jsonData = ko.toJSON(my_model.todos);
      jsData = ko.toJS(my_model);
      console.log(jsonData);
      $.ajax('/create', {
        type: 'POST',
        contentType: 'application/json',
        dataType: 'json',
        data: jsonData,
        error: function(jqXHR, textStatus, errorThrown) {
          console.log(jqXHR);
          console.log(textStatus);
          console.log(errorThrown);
          return alert("error");
        },
        success: function(data, textStatus, jqXHR) {
          return alert("success");
        }
      });
    });
  });

}).call(this);
