<template>
   <div class="house-container">
    <h1 class="font-weight-bold mb-7">{{ house.name  }}</h1>
    <p><strong>Words:</strong> {{ house.words }}</p>
    <p><strong>Region:</strong> {{ house.region }}</p>
    <p><strong>Coat of Arms:</strong> {{ house.coatOfArms }}</p>
    <p><strong>Lord:</strong> {{ house.currentLord }}</p>
  </div>
</template>

<script>
export default {
  name: 'HouseInfo',
  props: {
    house: Object
  }
};
</script>

<style scoped>
.house-container {
  padding: 10px;
  margin-bottom: 10px;
  text-align: center;
}
</style>