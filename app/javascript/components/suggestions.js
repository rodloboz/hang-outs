import { setCallback, sendRequest } from 'client/chat_notifications';

function submitRequest(form, chatId) {
  const startTime = form.querySelector('#appointment_start_time').value;
  sendRequest(startTime, chatId);

  console.log('sending request...')
  form.parentNode.remove();
};

function bindRequestEvent(form) {
  const chatId = form.getAttribute('action').split('/')[2];
  const submit = form.querySelector('.appointment-form--submit');

  submit.addEventListener('click', event => {
    event.preventDefault();
    submitRequest(form, chatId);
  });
};

function scrollToBottom(element) {
  // eslint-disable-next-line
  element.scrollTop = element.scrollHeight;
}

const messages = document.querySelector('.messages');

if (messages) {
  const content = messages.querySelector(".messages--content");

  scrollToBottom(content);

  // Telling `chat.js` to call this piece of code whenever a new message is received
  // over ActionCable
  setCallback(({message}) => {
    const div = document.createElement('div');

    div.innerHTML = message;

    const dismiss = div.querySelector('.appointment-dismiss');
    const form = div.querySelector('#new_appointment');

    if (dismiss) dismiss.addEventListener('click', () => div.remove());
    content.appendChild(div);
    // content.insertAdjacentHTML("beforeend", div);

    if (form) bindRequestEvent(form);

    scrollToBottom(content);
  });
}
