import { setCallback } from '../client/notifications';

function markAsRead() {
  fetch('/notifications/mark_as_read', {
          method: 'post',
          headers: {
            'Content-Type': 'application/json',
            'X-CSRF-Token': Rails.csrfToken()
          },
          credentials: 'same-origin'
        })
  .then(response => {
    if (response.status === 200) {
      refreshCounter(0);
    }
  })
};

function refreshCounter(number) {
  const counterElement = document.getElementById('counter');
  counterElement.innerHTML = number;
};

const counterTrigger = document.querySelector('[data-behavior="notifications-counter"]');
const notifications = document.getElementById('notifications');
const counter = document.getElementById('counter');

if (notifications && counter) {
  setCallback(({notification, count}) => {
    notifications.insertAdjacentHTML("afterbegin", notification);
    counter.innerHTML = count;
  });
}

if (counterTrigger) {
  counterTrigger.addEventListener('click', markAsRead)
}
