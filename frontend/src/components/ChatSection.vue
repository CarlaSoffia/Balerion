<template>
  <v-container class="chatsection" fluid>
    <v-row>
      <!-- Left section -->
      <v-col class="full-height data" cols="7">
        <CharacterInfo :character="characterData"/>
      </v-col>

      <!-- Right section -->
      <v-col class="full-height chat" cols="5">
        <!-- Chat header -->
        <v-row align="center" no-gutters>
          <v-col cols="auto" class="mr-2">
            <v-img width="50" src="./../assets/targaryen.webp" />
          </v-col>
          <v-col cols="auto">
            <div class="title font-weight-bold">Balerion</div>
          </v-col>
        </v-row>

        <!-- Chat messages -->
        <v-row
          class="d-flex"
          style="max-height: calc(100vh - 200px); overflow-y: auto"
          ref="messagesContainer"
        >
          <v-col cols="12">
            <v-row v-for="(message, index) in messages" :key="index">
              <v-col cols="auto">
                <v-card
                  class="pa-2 mt-1"
                  outlined
                  style="background-color: #444654"
                >
                  <div style="color: #d9d9e3" class="caption">
                    {{ message.author }}
                  </div>
                  <div style="color: #d9d9e3" class="message">
                    {{ message.text }}
                  </div>
                </v-card>
              </v-col>
            </v-row>
          </v-col>
        </v-row>

        <!-- Chat input -->
        <v-container no-gutters class="fixed-bottom">
          <v-row no-gutters>
            <v-text-field
              v-model="message"
              label="Type a message"
              filled
              hide-details
              @keyup.enter="sendMessage"
              class="texts mr-1"
            />
            <v-btn
              @click="sendMessage"
              class="mt-2"
              fab
              dark
              small
              color="dark"
            >
              <v-icon dark> mdi-send </v-icon>
            </v-btn>
          </v-row>
        </v-container>
      </v-col>
    </v-row>
  </v-container>
</template>

<script>
import CharacterInfo from './CharacterInfo';

export default {
  name: "ChatSection",
  components: {
    CharacterInfo,
  },
  data() {
    return {
      messages: [
        {
          author: "Balerion 🐉",
          text: "Hello!",
          isUser: false,
        },
        {
          author: "Balerion 🐉",
          text: "Feel free to ask me about a character, house, or book in GoT or HoTD.",
          isUser: false,
        },
      ],
      message: "",
      characterData:{
        "name": "Jon Snow",
        "gender": "Male",
        "culture": "Northmen",
        "born": "In 283 AC",
        "died": "",
        "titles": [
            "Lord Commander of the Night's Watch"
        ],
        "aliases": [
            "Lord Snow",
            "Ned Stark's Bastard",
            "The Snow of Winterfell",
            "The Crow-Come-Over",
            "The 998th Lord Commander of the Night's Watch",
            "The Bastard of Winterfell",
            "The Black Bastard of the Wall",
            "Lord Crow"
        ],
        "father": "",
        "mother": "",
        "spouse": "",
        "allegiances": [
            "https://www.anapioficeandfire.com/api/houses/362"
        ],
        "playedBy": [
            "Kit Harington"
        ]
      }
    };
  },
  methods: {
    sendMessage() {
      if(this.message == ""){
        return;
      }
      this.messages.push({
        author: "You 👤",
        text: this.message,
        isUser: true,
      });
      this.message = "";
      this.scrollToBottom();
    },
    scrollToBottom() {
      this.$nextTick(() => {
        this.$refs.messagesContainer.scrollTop =
          this.$refs.messagesContainer.scrollHeight;
      });
    },
  },
};
</script>
<style>
html,
body {
  overflow: hidden;
}
.chatsection {
  color: #d9d9e3;
}
.full-height {
  height: 100vh;
}
.data {
  background-color: #202123;
}
.chat {
  background-color: #343541;
}
.fixed-bottom {
  position: fixed;
  bottom: 0;
  width: 40%;
}
.texts {
  background-color: #444654;
}
</style>