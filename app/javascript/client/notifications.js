import createChannel from 'client/cable';

let callback; // declaring a variable that will hold a function later

const notifications = createChannel('NotificationsChannel', {
  received(data) {
    if (callback) callback.call(null, data);
  }
});

function setCallback(fn) {
  callback = fn;
}

export { setCallback };
