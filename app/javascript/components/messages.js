import { setCallback } from 'client/chat';

function scrollToBottom(element) {
  // eslint-disable-next-line
  console.log(element.scrollTop)
  console.log(element.scrollHeight)
  element.scrollTop = element.scrollHeight;
}

const messages = document.querySelector('.messages');

if (messages) {
  const content = messages.querySelector(".messages--content");

  scrollToBottom(content);

  // Telling `chat.js` to call this piece of code whenever a new message is received
  // over ActionCable
  setCallback(message => {
    content.insertAdjacentHTML("beforeend", message);

    scrollToBottom(content);
  });
}
