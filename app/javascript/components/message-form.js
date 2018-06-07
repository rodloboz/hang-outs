// we need to import sendMessage from our client/chat.js
import { sendMessage } from "../client/chat";

function submitMessage(inputMessage, inputChatId) {
  // Invokes sendMessage, that, in turn, invokes Ruby send_message method
  // that will create a Message instance with ActiveRecord
  sendMessage(inputMessage.value, inputChatId.value);

  // eslint-disable-next-line
  inputMessage.value = "";
  inputMessage.focus();
}

const form = document.getElementById('new_message');

if (form) {
  const inputMessage = form.querySelector('.message-form--input');
  const inputChatId = form.querySelector('#message_chat_id');
  const submit = form.querySelector('.message-form--submit');

  // You can send a message with cmd/ctrl+enter
  inputMessage.addEventListener('keydown', event => {
    if (event.keyCode === 13 && event.metaKey) {
      event.preventDefault();
      submitMessage(inputMessage, inputChatId);
    }
  });

  // Or by cicking a button
  submit.addEventListener('click', event => {
    event.preventDefault();
    submitMessage(inputMessage, inputChatId);
  });
}
