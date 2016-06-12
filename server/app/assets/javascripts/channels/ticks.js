App.ticks = App.cable.subscriptions.create("TicksChannel", {
  connected: function() {
    // Called when the subscription is ready for use on the server
    $('.cable.status').text('Online');
  },

  disconnected: function() {
    // Called when the subscription has been terminated by the server
    $('.cable.status').text('Offline');
  },

  received: function(data) {
    // Called when there's incoming data on the websocket for this channel
    insert_message(JSON.parse(data), 'cable')
  }
});
