<template lang="pug">
header.card-header
  div.card-header-title.has-background-royalblue
    div
      div.field
        input.input(
          placeholder="Search label"
          type="text"
          v-model="searchLabel"
        )
      div.field.is-grouped.is-grouped-multiline(v-if="searchLabel")
        div.control(v-for="label in filteredLabels")
          div.tags.has-addons
            a.tag.is-medium(
              v-bind:style="{ \
                color: label.text_color, \
                backgroundColor: label.background_color \
              }"
              v-on:click="annotate(label.id)"
            ) {{ label.text }}
</template>

<style scoped>
.card-header-title {
  padding: 1.5rem;
}
</style>

<script>
export default {
  props: {
    annotate: {
      type: Function,
      required: true,
    },
    labels: {
      type: Array,
      required: true,
    },
  },
  data: () => ({
    searchLabel: '',
  }),
  computed: {
    filteredLabels() {
      return this.labels.filter(label => label.text.toLowerCase().includes(this.searchLabel.toLowerCase()));
    }
  },
};
</script>
