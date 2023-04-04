<template>
  <v-app>
    <v-main>
      <ChatSection class="custom-font"/>
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
<style scoped>
@import url('@/assets/trajan.css');

.custom-font {
  font-family: 'Trajanus Roman' !important;
}
</style>