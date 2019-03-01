import createChannel from 'client/cable';

let callback; // declaring a variable that will hold a function later

const chatNotifications = createChannel('ChatNotificationsChannel', {
  received(data) {
    if (callback) callback.call(null, data);
  }
});

function sendRequest(startTime, chatId) {
  chatNotifications.perform('request_appointment', { start_time: startTime, id: chatId});
};

function setCallback(fn) {
  callback = fn;
}

export { setCallback, sendRequest };
