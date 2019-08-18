<template>
  <v-card>
    <v-card-title>
      <span class="headline">{{ title }}</span>
    </v-card-title>

    <v-card-text>
      <v-container>
        <v-row>
          <v-col cols="12" sm="7" md="4">
            <v-text-field v-model="item.name" label="Car name"></v-text-field>
            <v-label v-if="validationError.name">Name is a required field.</v-label>
          </v-col>
          <v-col cols="12" sm="2" md="2">
            <v-text-field v-model="item.count" label="Count"></v-text-field>
          </v-col>
          <v-col cols="12" sm="9" md="6">
            <v-text-field v-model="item.time" label="Time"></v-text-field>
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
</template>

<script>
export default {
  name: "EditDialog",
  props: ["title", "item", "itemIndex"],
  methods: {
    validateData() {
      if (!this.item.name) this.validationError.name = true;
      else this.validationError.name = false;
      if (!Date.parse(this.item.time)) this.validationError.time = true;
      else this.validationError.time = false;

      if (!this.validationError.name && !this.validationError.time) {
        return true;
      } else {
        return false;
      }
    },
    close() {
      this.validationError.name = false;
      this.validationError.time = false;

      this.$emit("close");
    },
    save() {
      //save only if data is valid
      if (this.validateData()) {
        this.loading = true;

        if (this.item.count) this.item.count = Number(this.item.count);

        //update a entry
        if (this.itemIndex > -1) {
          axios
            .put(`http://localhost:3000/cars/${this.item._id}`, this.item)
            .then(response => {
              this.$emit("updateCar", {
                index: this.itemIndex,
                item: this.item
              });

              this.loading = false;
              this.close();
            })
            .catch(error => {
              this.loading = false;
              this.close();
              console.log(error);

              this.$emit(
                "displayError",
                `Error while updating car with id: ${this.item._id}`
              );
            });
        }
        //create new entry
        else {
          axios
            .post("http://localhost:3000/cars", this.item)
            .then(response => {
              this.$emit("pushCar", this.item);

              //save the new Id to car obj
              this.item._id = response.data.insertedId;
              this.loading = false;
              this.close();
            })
            .catch(error => {
              this.loading = false;
              this.close();
              console.log(error);

              this.$emit("displayError", "Error while saving new car.");
            });
        }
      }
    }
  },
  data: () => ({
    loading: false,
    validationError: {
      name: false,
      time: false
    }
  })
};
</script>
