<template>
  <div class="character-container">
    <h1 class="font-weight-bold mb-7">{{ character.name }}</h1>
    <p><strong>Gender:</strong> {{ character.gender }}</p>
    <p><strong>Culture:</strong> {{ character.culture }}</p>
    <p><strong>Born:</strong> {{ character.born }}</p>
    <p><strong>Titles:</strong> {{ character.titles.join(', ') }}</p>
    <p><strong>Aliases:</strong> {{ character.aliases.join(', ') }}</p>
    <p><strong>Played by:</strong> {{ character.playedBy.join(', ') }}</p>
  </div>
</template>

<script>
export default {
  name: 'CharacterInfo',
  props: {
    character: Object
  }
};
</script>

<style scoped>
.character-container {
  padding: 10px;
  margin-bottom: 10px;
  text-align: center;
}
</style>
