// TryMongo
//
// Copyright (c) 2009 Kyle Banker
// Licensed under the MIT Licence.
// http://www.opensource.org/licenses/mit-license.php

// Readline class to handle line input.
var ReadLine = function(options) {
  this.options      = options || {};
  this.htmlForInput = this.options.htmlForInput;
  this.inputHandler = this.options.handler;
  this.terminal     = $(this.options.terminalId || "#terminal");
  this.lineClass    = this.options.lineClass || '.readLine';
  this.history      = [];
  this.historyPtr   = 0;

  this.initialize();
};

ReadLine.prototype = {

  initialize: function() {
    this.addInputLine();
  },

  // Enter a new input line with proper behavior.
  addInputLine: function(stackLevel) {
    stackLevel = stackLevel || 0;
    this.terminal.append(this.htmlForInput(stackLevel));
    var ctx = this;
    ctx.activeLine = $(this.lineClass + '.active');

    // Bind key events for entering and navigting history.
    ctx.activeLine.bind("keydown", function(ev) {
      switch (ev.keyCode) {
        case EnterKeyCode:
          ctx.processInput(this.value);
          break;
        case UpArrowKeyCode:
          ctx.getCommand('previous');
          break;
        case DownArrowKeyCode:
          ctx.getCommand('next');
          break;
      }
    });

    this.activeLine.focus();
  },

  // Returns the 'next' or 'previous' command in this history.
  getCommand: function(direction) {
    if(this.history.length === 0) {
      return;
    }
    this.adjustHistoryPointer(direction);
    this.activeLine[0].value = this.history[this.historyPtr];
    $(this.activeLine[0]).focus();
    //this.activeLine[0].value = this.activeLine[0].value;
  },

  // Moves the history pointer to the 'next' or 'previous' position.
  adjustHistoryPointer: function(direction) {
    if(direction == 'previous') {
      if(this.historyPtr - 1 >= 0) {
        this.historyPtr -= 1;
      }
    }
    else {
      if(this.historyPtr + 1 < this.history.length) {
        this.historyPtr += 1;
      }
    }
  },

  // Return the handler's response.
  processInput: function(value) {
    value = value.trim();
    if (!value) {
      // deactivate the line...
      this.activeLine.value = "";
      this.activeLine.attr({disabled: true});
      this.activeLine.removeClass('active');

      // and add add a new command line.
      this.addInputLine();
      return

    } else if (value == 'clear') {
      this.clear();
      return
    }

    var me = this;
    me.inputHandler(value, function(response) {
      me.insertResponse(response);

      // Save to the command history...
      if((lineValue = value.trim()) !== "") {
        me.history.push(lineValue);
        me.historyPtr = me.history.length;
      }

      // deactivate the line...
      me.activeLine.value = "";
      me.activeLine.attr({disabled: true});
      me.activeLine.removeClass('active');

      // and add add a new command line.
      me.addInputLine();
    });
  },

  insertResponse: function(response) {
    if(response.length < 3) {
      this.activeLine.parent().append("<p class='response'></p>");
    }
    else {
      this.activeLine.parent().append("<p class='response'>" + response + "</p>");
    }
  },

  clear: function() {
    this.terminal.empty();
    this.addInputLine();
  },

  focus: function() {
    this.activeLine.focus();
  }
};

var EnterKeyCode     = 13;
var UpArrowKeyCode   = 38;
var DownArrowKeyCode = 40;