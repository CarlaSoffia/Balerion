<template>
  <div class="character-container scrollable-content" ref="content">
    <h1 class="mb-4 text-center"><strong>{{ character.name }}</strong></h1>
    <p v-if="character.gender">
      <strong>Gender:</strong> {{ character.gender }}
    </p>
    <p v-if="character.culture">
      <strong>Culture:</strong> {{ character.culture }}
    </p>
    <p v-if="character.born"><strong>Born:</strong> {{ character.born }}</p>
    <p v-if="character.died"><strong>Died:</strong> {{ character.died }}</p>
    <p v-if="character.father">
      <strong>Father:</strong> {{ character.father }}
    </p>
    <p v-if="character.mother">
      <strong>Mother:</strong> {{ character.mother }}
    </p>
    <p v-if="character.spouse">
      <strong>Spouse:</strong> {{ character.spouse }}
    </p>
    <p v-if="character.titles && character.titles.length > 0">
      <strong>Titles:</strong>
        <ul>
          <li v-for="(title, index) in character.titles" :key="index">
            {{ title }}
          </li>
        </ul>
    </p>
    <p v-if="character.aliases && character.aliases.length != 0">
     <strong>Aliases:</strong>
        <ul>
          <li v-for="(alias, index) in character.aliases" :key="index">
            {{ alias }}
          </li>
        </ul>
    </p> 
    <p v-if="character.allegiances && character.allegiances.length != 0">
     <strong>Allegiances:</strong>
        <ul>
          <li v-for="(allegiance, index) in character.allegiances" :key="index">
            {{ allegiance }}
          </li>
        </ul>
    </p> 
  </div>
</template>

<script>
export default {
  name: "CharacterInfo",
  props: {
    character: {
      type: Object,
      required: true,
    },
  },
};
</script>
<style scoped>
.character-container {
  overflow-y: auto;
  max-height: 85%;
}
.scrollable-content::-webkit-scrollbar {
  display: none !important;
}
</style>