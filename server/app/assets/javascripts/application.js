// This is a manifest file that'll be compiled into application.js, which will include all the files
// listed below.
//
// Any JavaScript/Coffee file within this directory, lib/assets/javascripts, vendor/assets/javascripts,
// or any plugin's vendor/assets/javascripts directory can be referenced here using a relative path.
//
// It's not advisable to add code directly here, but if you do, it'll appear at the bottom of the
// compiled file. JavaScript code in this file should be added after the last require_* statement.
//
// Read Sprockets README (https://github.com/rails/sprockets#sprockets-directives) for details
// about supported directives.
//
//= require jquery
//= require jquery_ujs
//= require webstomp
//= require_tree .

function insert_message(message, source) {
  var $element = $('tbody#messages tr[title='+message.id+']')
  if(!$element.length)
    $element = $('<tr title="'+message.id+'"><td class="cable"></td><td class="rabbit"></td></tr>').appendTo('tbody#messages');
  $('.'+source, $element).append($("<p>").text(message.content));
}

// http://stackoverflow.com/a/2117523/338859
function random_uuid() {
  return 'xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx'.replace(/[xy]/g, function(c) {
    var r = Math.random()*16|0, v = c == 'x' ? r : (r&0x3|0x8);
    return v.toString(16);
  });
}

// http://stackoverflow.com/a/36807854/338859
function tab_id() {
  return sessionStorage.tabID ? sessionStorage.tabID : sessionStorage.tabID = random_uuid();
}

$(function () {
  this.connect = function () {
    // var client = Stomp.client('ws://' + window.location.hostname + ':15674/ws');
    var ws = new WebSocket('ws://' + window.location.hostname + ':15674/ws');
    var client = webstomp.over(ws);
    client.debug = function(str) {
      console.debug('RabbitMQ WebStomp Debug:', str);
    };
    client.onreceive = function(m) {
      console.info('RabbitMQ WebStomp Received:', m);
    }
    var on_connect = function(x) {
      var subscription = client.subscribe("/exchange/ticks/ticks", function(message) {
        var content = JSON.parse(message.body)
        insert_message(content, 'rabbit');
        message.ack();
      }, {
        'ack':            'client-individual',     // Каждое сообщение подтверждается отдельно
        'durable':        true,                    // Подписка остаётся после отключения
        'auto-delete':    false,                   // И не удаляется после отключения
        'x-expires':      24*60*60*1000,           // Но удаляется после суток неактивности (вообще надо через policies)
        'id':             tab_id(),                // Уникальный случайный идентификатор (у каждой вкладки свой)
        'x-queue-name':   "web-client-"+tab_id(),  // Даём очереди, которая обеспечивает данную подписку, говорящее имя
        'x-max-priority': 10,
      });
    };
    var on_error = function() {
      console.error('RabbitMQ WebStomp Error:', arguments);
    };
    client.connect('guest', 'guest', on_connect, on_error, '/');

    // Socket reconnect

    var old_onopen = ws.onopen;
    ws.onopen = function(e) {
      console.info('WebSocket connection open:', e, ws);
      if (this.reconnector) this.reset_reconnect();
      this.connected = true;
      old_onopen(e);
      $('.rabbit.status').text('Online');
    }.bind(this);

    var old_onclose = ws.onclose;
    ws.onclose = function (e) {
      console.info('WebSocket connection closed:', e);
      this.connected = false;
      if (!e.wasClean || e.reason === 'STOMP died') { // FIXME: Непонятно, можно ли полагаться на STOMP died
        console.warn('WebSocket connection closed unexpectedly with reason:', e.reason);
        this.reconnect();
      }
      old_onclose();
      $('.rabbit.status').text('Offline');
    }.bind(this);

    var old_onerror = ws.onerror;
    ws.onerror = function (e) {
      console.debug('WebSocket connection error:', arguments);
      old_onerror();
    }.bind(this);
  }.bind(this);

  this.reconnect = function () {
    if (this.reconnect_tries) {
      const delay = Math.min(this.reconnect_tries * 1000, 15000);
      console.debug(`Will try to reconnect to SockJS in ${delay}ms`);
      this.reconnector = setTimeout(this.connect.bind(this), delay);
    } else {
      this.connect();
    }

    this.reconnect_tries++;
  }.bind(this);

  this.reset_reconnect = function () {
    clearTimeout(this.reconnector);
    this.reconnect_tries = 0;
  }.bind(this);

  this.connect();

});
