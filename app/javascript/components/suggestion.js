import { sendRequest } from '../client/chat';

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

export { bindRequestEvent };
