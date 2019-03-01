import Rails from 'rails-ujs';
import { setCallback, sendRequest } from 'client/chat_notifications';

function submitRequest(form, chatId) {
  const startTime = form.querySelector('#appointment_start_time').value;
  sendRequest(startTime, chatId);

  form.parentNode.remove();
};

function bindSuggestionEvents(form) {
  const chatId = form.getAttribute('action').split('/')[2];
  const submit = form.querySelector('.appointment-form--submit');

  submit.addEventListener('click', event => {
    event.preventDefault();
    submitRequest(form, chatId);
  });
};

function bindRequestEvents(request) {
  const appointmentId = request.dataset.appointmentid;
  const rejectBtn = request.querySelector('.btn-reject');
  const acceptBtn = request.querySelector('.btn-accept');

  rejectBtn.addEventListener('click', event => {
    event.preventDefault();
    fetch(`/appointments/${appointmentId}/reject`, {
      method: 'post',
      headers: {
        'Content-Type': 'application/json',
        'X-CSRF-Token': Rails.csrfToken()
      },
      credentials: 'same-origin'
    })
      .then(response => request.remove());
  });

  acceptBtn.addEventListener('click', event => {
    event.preventDefault();
    fetch(`/appointments/${appointmentId}/accept`, {
      method: 'post',
      headers: {
        'Content-Type': 'application/json',
        'X-CSRF-Token': Rails.csrfToken()
      },
      credentials: 'same-origin'
    })
      .then(response => request.remove());
  });
};

function scrollToBottom(element) {
  // eslint-disable-next-line
  element.scrollTop = element.scrollHeight;
}

const messages = document.querySelector('.messages');

if (messages) {
  const content = messages.querySelector(".messages--content");

  const requests = document.querySelectorAll('.chat_appointment.request');

  requests.forEach(request => bindRequestEvents(request));

  scrollToBottom(content);

  // Telling `chat.js` to call this piece of code whenever a new message is received
  // over ActionCable
  setCallback(({message}) => {
    const div = document.createElement('div');

    div.innerHTML = message;

    const dismiss = div.querySelector('.appointment-dismiss');
    const form = div.querySelector('#new_appointment');
    const request = div.querySelector('.chat_appointment.request');

    if (dismiss) dismiss.addEventListener('click', () => div.remove());
    content.appendChild(div);
    // content.insertAdjacentHTML("beforeend", div);

    if (form) bindSuggestionEvents(form);

    if (request) bindRequestEvents(request);

    scrollToBottom(content);
  });
}
