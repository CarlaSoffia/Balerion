<template>
  <v-app>
    <v-main>
      <ChatSection/>
    </v-main>
  </v-app>
</template>

<script>
import ChatSection from './components/ChatSection';

export default {
  name: 'App',

  components: {
    ChatSection,
  },

  data: () => ({
    //
  }),
};
</script>
