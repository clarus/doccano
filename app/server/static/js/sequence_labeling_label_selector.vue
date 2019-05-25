<template lang="pug">
header.card-header
  div.card-header-title.has-background-royalblue
    div
      div.field
        div.control
          input.input(
            placeholder="Search label"
            type="text"
            v-model="searchLabel"
          )
      div.field.is-grouped.is-grouped-multiline
        div.control(v-for="label in filteredLabels.labels")
          div.tags.has-addons
            a.tag.is-medium(
              v-bind:style="{ \
                color: label.text_color, \
                backgroundColor: label.background_color \
              }"
              v-on:click="annotate(label.id)"
            ) {{ label.text }}
        p.has-text-white(v-if="filteredLabels.hasMore") ...

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
      const maxNbOfResults = 25;
      const labels = this.labels.filter(
        label => label.text.toLowerCase().includes(this.searchLabel.toLowerCase()),
      );

      return {
        hasMore: labels.length > maxNbOfResults,
        labels: labels.slice(0, maxNbOfResults),
      };
    },
  },
};
</script>
