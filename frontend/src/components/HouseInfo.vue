<template>
   <div class="house-container scrollable-content">
    <h1 class="mb-4 text-center"><strong>{{ house.name }}</strong></h1>
    <p v-if="house.words">
      <strong>Words:</strong> {{ house.words }}
    </p>
    <p v-if="house.coatOfArms">
      <strong>Coat of Arms:</strong> {{ house.coatOfArms }}
    </p>
    <p v-if="house.region">
      <strong>Region:</strong> {{ house.region }}
    </p>
    <p v-if="house.seats && house.seats.length > 0">
     <strong>Seats:</strong>
        <ul>
          <li v-for="(seat, index) in house.seats" :key="index">
            {{ seat }}
          </li>
        </ul>
    </p>
    <p v-if="house.titles && house.titles.length > 0">
     <strong>Titles:</strong>
        <ul>
          <li v-for="(title, index) in house.titles" :key="index">
            {{ title }}
          </li>
        </ul>
    </p> 
    <p v-if="house.founder">
      <strong>Founder:</strong> {{ house.founder }}
    </p>
    <p v-if="house.swornMembers && house.swornMembers.length > 0">
     <strong>Sworn Members:</strong>
        <ul>
          <li v-for="(swornMember, index) in house.swornMembers" :key="index">
            {{ swornMember }}
          </li>
        </ul>
    </p> 
    <p v-if="house.ancestralWeapons && house.ancestralWeapons.length > 0">
     <strong>Ancestral Weapons:</strong>
        <ul>
          <li v-for="(ancestralWeapon, index) in house.ancestralWeapons" :key="index" >
            {{ ancestralWeapon }}
          </li>
        </ul>
    </p>  
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
  overflow-y: auto;
  height: 100%;
}
.scrollable-content::-webkit-scrollbar {
  width: 0 !important;
  height: 0 !important;
  display: none !important;
}
</style>