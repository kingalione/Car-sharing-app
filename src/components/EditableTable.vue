<template>
  <div>
    <template>
      <v-alert
        :value="errorOccurred"
        dark
        color="error"
        icon="mdi-home"
        transition="scale-transition"
      >{{ errorMessage }}</v-alert>
    </template>
    <v-data-table :headers="headers" :items="cars" sort-by="name" class="elevation-1">
      <template v-slot:top>
        <v-toolbar flat color="white">
          <v-toolbar-title>Location: Alsdorf</v-toolbar-title>
          <v-divider class="mx-4" inset vertical></v-divider>
          <v-spacer></v-spacer>
          <v-dialog v-model="dialog" max-width="500px">
            <template v-slot:activator="{ on }">
              <v-btn color="primary" dark class="mb-2" v-on="on">New Entry</v-btn>
            </template>
            <EditDialog
              v-bind:title="formTitle"
              v-bind:item="editedItem"
              v-bind:itemIndex="editedIndex"
              v-on:close="close()"
              v-on:updateCar="updateCar($event)"
              v-on:pushCar="pushCar($event)"
              v-on:displayError="displayError($event)"
            ></EditDialog>
          </v-dialog>
        </v-toolbar>
      </template>
      <template v-slot:item.action="{ item }">
        <v-icon small class="mr-2" @click="editItem(item)">edit</v-icon>
        <v-icon small @click="deleteItem(item)">delete</v-icon>
      </template>
      <template v-slot:no-data>
        <v-btn color="primary" @click="initialize">Reload table</v-btn>
      </template>
    </v-data-table>
  </div>
</template>

<script>
import axios from "axios";
import EditDialog from "./EditDialog.vue";

const ERR_MSG_TIMEOUT = 5000;

export default {
  components: {
    EditDialog
  },
  data: () => ({
    errorOccurred: false,
    errorMessage: "",
    dialog: false,
    headers: [
      {
        text: "Car name",
        align: "left",
        sortable: false,
        value: "name"
      },
      { text: "Count", value: "count" },
      { text: "Last update", value: "time" },
      { text: "Actions", value: "action", sortable: false }
    ],
    cars: [],
    editedIndex: -1,
    editedItem: {
      name: "",
      count: 0,
      time: new Date().toISOString()
    },
    defaultItem: {
      name: "",
      count: 0,
      time: new Date().toISOString()
    }
  }),
  computed: {
    formTitle() {
      return this.editedIndex === -1 ? "New Item" : "Edit Item";
    }
  },
  watch: {
    dialog(val) {
      val || this.close();
    }
  },
  created() {
    this.initialize();
  },
  methods: {
    initialize() {
      this.load();
    },
    updateCar(carObj) {
      Object.assign(this.cars[carObj.index], carObj.item);
    },
    pushCar(car) {
      this.cars.push(car);
    },
    displayError(errorMessage) {
      this.displayErrorMessage(errorMessage);
    },
    displayErrorMessage(message) {
      this.errorOccurred = true;
      this.errorMessage = message;
      setTimeout(() => {
        this.errorOccurred = false;
      }, ERR_MSG_TIMEOUT);
    },
    editItem(item) {
      this.editedIndex = this.cars.indexOf(item);
      this.editedItem = Object.assign({}, item);
      this.dialog = true;
    },
    deleteItem(item) {
      if (confirm("Are you sure you want to delete this item?") === true) {
        axios
          .delete(`http://localhost:3000/cars/${item._id}`)
          .then(response => {
            const index = this.cars.indexOf(item);
            this.cars.splice(index, 1);
          })
          .catch(error => {
            console.log(error);

            this.displayErrorMessage(
              `Error while deleting car with id: ${item._id}`
            );
          });
      }
    },
    close() {
      this.dialog = false;

      setTimeout(() => {
        this.editedItem = Object.assign({}, this.defaultItem);
        this.editedIndex = -1;
      }, 300);
    },
    load() {
      axios
        .get("http://localhost:3000/cars")
        .then(({ data }) => {
          this.cars = data;
        })
        .catch(error => {
          console.log(error);

          this.displayErrorMessage("Error while loading cars.");
        });
    }
  }
};
</script>
