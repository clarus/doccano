<template lang="pug">
extends ./annotation.pug

block annotation-area
  div.card
    header.card-header
      div.card-header-title.has-background-royalblue(style={flexDirection: 'column'})
        div.field.is-grouped.is-grouped-multiline(
          style={paddingBottom: '20px'}
          v-for="labelsGroup in getLabelsToPresent()"
        )
          div.control(v-for="label in labelsGroup")
            div.tags.has-addons
              a.tag.is-medium(v-on:click="addLabel(label)") {{ getLabelText(label) }}

    div.card-content
      div.field.is-grouped.is-grouped-multiline
        div.control(v-for="annotation in annotations[pageNumber]")
          div.tags.has-addons(v-if="id2label[annotation.label]")
            span.tag.is-medium(
              v-bind:style="{ \
                color: id2label[annotation.label].text_color, \
                backgroundColor: id2label[annotation.label].background_color \
              }"
            ) {{ id2label[annotation.label].text }}
              button.delete.is-small(v-on:click="removeLabel(annotation)")

      hr
      div.content(v-if="docs[pageNumber]")
        span.text {{ docs[pageNumber].text }}
</template>

<style scoped>
hr {
  margin: 0.8rem 0;
}

.card-header-title {
  padding: 1.5rem;
}
</style>

<script>
import annotationMixin from './annotationMixin';
import HTTP from './http';
import { simpleShortcut } from './filter';

export default {
  filters: { simpleShortcut },

  mixins: [annotationMixin],

  data() {
    return {
      labelPath: [],
    };
  },

  methods: {
    getAnnotation(label) {
      return this.annotations[this.pageNumber].find(annotation => annotation.label === label.id);
    },

    getLabelText(label) {
      const splitLabel = label.split('/');

      return splitLabel[splitLabel.length - 1];
    },

    getSplitLabels() {
      return this.labels.map(label => label.text.split('/'));
    },

    isLabelAtPath(splitLabel, path) {
      return path.every((pathComponent, index) => splitLabel[index] === pathComponent);
    },

    getPossibleLabelHeadsAtPath(path) {
      const possibleSplitLabels = this.getSplitLabels().filter(
        splitLabel => this.isLabelAtPath(splitLabel, path),
      );
      const possibleLabelHeads = possibleSplitLabels.map(splitLabel => splitLabel.slice(0, path.length + 1).join('/'));

      return [...new Set(possibleLabelHeads)];
    },

    getLabelsToPresent() {
      return this.labelPath.reduce(
        ({ previousLabelsToPresent, previousPath }, pathComponent) => {
          const path = [...previousPath, pathComponent];

          return {
            previousLabelsToPresent: [
              ...previousLabelsToPresent,
              this.getPossibleLabelHeadsAtPath(path),
            ],
            previousPath: path,
          };
        },
        {
          previousLabelsToPresent: [this.getPossibleLabelHeadsAtPath([])],
          previousPath: [],
        },
      ).previousLabelsToPresent;
    },

    async submit() {
      const state = this.getState();
      this.url = `docs?q=${this.searchQuery}&doc_annotations__isnull=${state}&offset=${this.offset}`;
      await this.search();
      this.pageNumber = 0;
    },

    async addLabel(label) {
      const labelDescriptor = this.labels.find(({ text }) => text === label);

      if (labelDescriptor) {
        const annotation = this.getAnnotation(label);

        if (annotation) {
          this.removeLabel(annotation);
        } else {
          const docId = this.docs[this.pageNumber].id;
          const payload = {
            label: labelDescriptor.id,
          };
          await HTTP.post(`docs/${docId}/annotations`, payload).then((response) => {
            this.annotations[this.pageNumber].push(response.data);
          });
        }
      } else {
        this.labelPath = label.split('/');
      }
    },
  },
};
</script>
