<template>
  <div>
    <v-dialog v-model="show" max-width="500" persistent>
      <v-card>
        <v-card-title>
          <v-img class="mb-3 mt-2 trajan" src="./../assets/series.webp"></v-img>
        </v-card-title>
        <v-card-text>
          <h2 class="mb-2 trajan">Please enter your name:</h2>
          <v-text-field class="trajan" v-model="name" hide-details @keyup.enter="submitName" />
        </v-card-text>
        <v-card-actions class="d-flex justify-center">
          <v-btn @click="submitName" fab dark>
            <v-icon size="32" dark>mdi-login-variant</v-icon>
          </v-btn>
        </v-card-actions>
      </v-card>
    </v-dialog>

    <v-container class="chatsection" fluid>
      <v-row>
        <!-- Left section -->
        <v-col class="full-height data" cols="7">
          <v-img class="mb-4 image" width="500" src="./../assets/series.webp"></v-img>
          <CharacterInfo v-if="isFilled && !isHouse" :character="dataShow" />
          <HouseInfo v-if="isFilled && isHouse" :house="dataShow" />
        </v-col>
        <!-- Right section -->
        <v-col class="full-height chat" cols="5">
          <!-- Chat header -->
          <v-row align="center" no-gutters>
            <v-col cols="auto" class="mr-4">
              <v-img width="70" src="./../assets/targaryen.webp" />
            </v-col>
            <v-col cols="auto">
              <h2><strong>Balerion the Black Dread</strong></h2>
            </v-col>
          </v-row>

          <!-- Chat messages -->
          <v-row
            class="d-flex scrollable-content"
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
                    <p style="color: #d9d9e3"> <strong>{{ message.author }}</strong></p>
                    <p style="color: #d9d9e3"> {{ message.text }}</p>
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
                filled
                hide-details
                @keyup.enter="sendMessage"
                class="texts mr-1 text-input-color"
              />
              <v-btn @click="sendMessage" class="mt-2" fab dark small>
                <v-icon dark> mdi-send </v-icon>
              </v-btn>
            </v-row>
          </v-container>
        </v-col>
      </v-row>
    </v-container>
  </div>
</template>

<script>
import CharacterInfo from "./CharacterInfo";
import HouseInfo from "./HouseInfo";
import axios from "axios";

export default {
  name: "ChatSection",
  components: {
    CharacterInfo,
    HouseInfo,
  },
  data() {
    return {
      show: true,
      name: "",
      messages: [],
      message: "",
      dataShow: {},
      isFilled: false,
      isHouse: false,
    };
  },
  methods: {
    submitName() {
      if (this.name != "") {
        this.show = false;
      }
    },
    sendMessage() {
      if (this.message == "" || this.name == "") {
        return;
      }

      this.messages.push({
        author: "You 👤",
        text: this.message,
        isUser: true,
      });
      this.scrollToBottom();
      this.sendRasa(this.message);
      this.message = "";
    },
    sendRasa(str) {
      var data = {
        sender: this.name,
        message: str,
      };
      axios
        .post(process.env.RASA, data, {
          headers: { "Content-Type": "application/json" },
        })
        .then((response) => {
          response.data.forEach((res) => {
            if (!res.text.includes("{")) {
              this.messages.push({
                author: "Balerion 🐉",
                text: res.text,
                isUser: false,
              });
            }
            if (res.text.includes("{") && !res.text.includes("Error")) {
              if (res.text.includes("gender")) {
                this.isFilled = true;
                this.isHouse = false;
              } else {
                this.isFilled = true;
                this.isHouse = true;
              }
              this.dataShow = JSON.parse(res.text);
              console.log(this.dataShow);
            }
          });
        })
        .catch((error) => {
          console.log(error);
        });
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
<style scoped>
@import url('@/assets/trajan.css');

.trajan {
  font-family: 'Trajanus Roman' !important;
}
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
.scrollable-content::-webkit-scrollbar {
  width: 0 !important;
  height: 0 !important;
  display: none !important;
}
.text-input-color .v-text-field__slot input, label {
   color: #d9d9e3 !important;
}
.image {
  display: block;
  margin-left: auto;
  margin-right: auto;
}
</style>