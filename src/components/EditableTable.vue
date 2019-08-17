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
            <v-card>
              <v-card-title>
                <span class="headline">{{ formTitle }}</span>
              </v-card-title>

              <v-card-text>
                <v-container>
                  <v-row>
                    <v-col cols="12" sm="7" md="4">
                      <v-text-field v-model="editedItem.name" label="Car name"></v-text-field>
                      <v-label v-if="validationError.name">Name is a required field.</v-label>
                    </v-col>
                    <v-col cols="12" sm="2" md="2">
                      <v-text-field v-model="editedItem.count" label="Count"></v-text-field>
                    </v-col>
                    <v-col cols="12" sm="9" md="6">
                      <v-text-field v-model="editedItem.time" label="Time"></v-text-field>
                      <v-label v-if="validationError.time">Time has to be in UTC/ISO8601</v-label>
                    </v-col>
                  </v-row>
                </v-container>
              </v-card-text>

              <v-card-actions>
                <v-spacer></v-spacer>
                <v-btn color="blue darken-1" text @click="close">Cancel</v-btn>
                <v-btn color="blue darken-1" :loading="loading" text @click="save">Save</v-btn>
              </v-card-actions>
            </v-card>
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

const ERR_MSG_TIMEOUT = 5000;

export default {
  data: () => ({
    errorOccurred: false,
    errorMessage: "",
    loading: false,
    dialog: false,
    validationError: {
      name: false,
      time: false
    },
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
    editItem(item) {
      this.editedIndex = this.cars.indexOf(item);
      this.editedItem = Object.assign({}, item);
      this.dialog = true;
    },
    displayErrorMessage(message) {
      this.errorOccurred = true;
      this.errorMessage = message;
      setTimeout(() => {
        this.errorOccurred = false;
      }, ERR_MSG_TIMEOUT);
    },
    validateData() {
      if (!this.editedItem.name) this.validationError.name = true;
      else this.validationError.name = false;
      if (!Date.parse(this.editedItem.time)) this.validationError.time = true;
      else this.validationError.time = false;

      if (!this.validationError.name && !this.validationError.time) {
        return true;
      } else {
        return false;
      }
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

      this.validationError.name = false;
      this.validationError.time = false;

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
    },
    save() {
      //save only if data is valid
      if (this.validateData()) {
        this.loading = true;

        if (this.editedItem.count)
          this.editedItem.count = Number(this.editedItem.count);

        //update a entry
        if (this.editedIndex > -1) {
          axios
            .put(
              `http://localhost:3000/cars/${this.editedItem._id}`,
              this.editedItem
            )
            .then(response => {
              Object.assign(this.cars[this.editedIndex], this.editedItem);

              this.loading = false;
              this.close();
            })
            .catch(error => {
              this.loading = false;
              this.close();
              console.log(error);

              this.displayErrorMessage(
                `Error while updating car with id: ${this.editedItem._id}`
              );
            });
        }
        //create new entry
        else {
          axios
            .post("http://localhost:3000/cars", this.editedItem)
            .then(response => {
              //save the new Id to car obj
              this.editedItem._id = response.data.insertedId;
              this.cars.push(this.editedItem);
              this.loading = false;
              this.close();
            })
            .catch(error => {
              this.loading = false;
              this.close();
              console.log(error);

              this.displayErrorMessage("Error while saving new car.");
            });
        }
      }
    }
  }
};
</script>