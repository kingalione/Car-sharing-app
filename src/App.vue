<template>
  <v-app>
    <v-app-bar app>
      <v-toolbar-title class="headline text-uppercase">
        <span>Vuetify</span>
        <span class="font-weight-light">MATERIAL DESIGN</span>
      </v-toolbar-title>
      <v-spacer></v-spacer>
    </v-app-bar>

    <v-content>
      <EditableTable />
    </v-content>
  </v-app>
</template>

<script lang="ts">
import Vue from "vue";
import EditableTable from "./components/EditableTable.vue";

export default Vue.extend({
  name: "App",
  components: {
    EditableTable
  },
  data: () => ({
    //
  })
});
</script>
