<template>
    <div class="container">
    <div class="left-side">
      <!-- Left side content here -->
    </div>
    <div class="right-side">
      <div class="chat-container">
        <div class="chat-header">
          <h2>Chat Section</h2>
        </div>
        <div class="chat-messages">
          <div class="message">
            <div class="message-header">
              <img src="https://via.placeholder.com/50x50" alt="Avatar">
              <h3>John Smith</h3>
            </div>
            <div class="message-body">
              <p>Hello, how can I help you?</p>
            </div>
          </div>
          <!-- More chat messages here -->
        </div>
        <div class="chat-input">
          <input type="text" placeholder="Who are the Targaryens?...">
          <button>Send</button>
        </div>
      </div>
    </div>
  </div>
</template>

<script>
  export default {
    name: "Balerion",
    data() {
      return {
        };
    }
  };
</script>

<style scoped>
 .container {
  display: flex;
  height: 100vh;
}

.left-side {
  width: 60%;
  height: 100%;
  background-color: lightgray;
  padding: 20px;
}

.right-side {
  width: 40%;
  height: 100%;
  background-color: white;
  padding: 20px;
  display: flex;
  flex-direction: column;
  justify-content: space-between;
}

.chat-container {
  flex: 1;
  display: flex;
  flex-direction: column;
}

.chat-header {
  background-color: #f4f4f4;
  padding: 10px;
  border-bottom: 1px solid #ddd;
}

.chat-messages {
  flex: 1;
  overflow-y: scroll;
  padding: 10px;
}

.message {
  display: flex;
  flex-direction: column;
  margin-bottom: 20px;
}

.message-header {
  display: flex;
  align-items: center;
  margin-bottom: 10px;
}

.message-header img {
  width: 50px;
  height: 50px;
  border-radius: 50%;
  margin-right: 10px;
}

.message-header h3 {
  margin: 0;
}

.message-body {
  background-color: #e8e8e8;
  padding: 10px;
  border-radius: 10px;
}

.chat-input {
  display: flex;
  justify-content: space-between;
  align-items: center;
  background-color: #f4f4f4;
  padding: 10px;
  border-top: 1px solid #ddd;
}

.chat-input input {
  flex: 1;
  height: 25px;
  margin-right: 10px;
}
</style>
