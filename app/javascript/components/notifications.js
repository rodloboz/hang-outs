function loadNotifications() {
  fetch('/notifications', {
          method: 'get',
          headers: {
            'Content-Type': 'application/json',
            'X-CSRF-Token': Rails.csrfToken()
          },
          credentials: 'same-origin'
        })
  .then(response => response.json())
  .then(data => {
    renderCounter(data.array.length);
    refreshNotifications(renderNotifications(data.array));
  })
};

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

function renderCounter(number) {
  counter.insertAdjacentHTML('afterbegin',
    `<span id="counter" class="notifications text-center">${number}</span>`
  )
};

function refreshCounter(number) {
  const counterElement = document.getElementById('counter');
  counterElement.innerHTML = number;
};

function renderNotifications(notifications) {
  return notifications.map(notification => {
    return(
      `<li class="notification">
      <strong>${notification.actor}</strong>
      ${notification.action}
      ${notification.notifiable.type}
      </li>
      `
    )
  }).join('');
};

function refreshNotifications(notificationsHTML) {
  const notifications = document.getElementById('notifications');
  notifications.innerHTML = notificationsHTML;
};

const notifications = document.querySelector('[data-behavior="notifications"]');
const counter = document.querySelector('[data-behavior="notifications-counter"]');

if (notifications) {
  loadNotifications()
}

if (counter) {
  counter.addEventListener('click', markAsRead)
}


