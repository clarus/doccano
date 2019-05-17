<template lang="pug">
extends ./annotation.pug

block annotation-area
  div.card
    SequenceLabelingLabelSelector(
      v-bind:annotate="annotate"
      v-bind:labels="labels"
    )

    div.card-content
      div.content(v-if="docs[pageNumber] && annotations[pageNumber]")
        annotator(
          v-bind:labels="labels"
          v-bind:entity-positions="annotations[pageNumber]"
          v-bind:text="docs[pageNumber].text"
          v-on:remove-label="removeLabel"
          v-on:add-label="addLabel"
          ref="annotator"
        )
</template>

<script>
import annotationMixin from './annotationMixin';
import Annotator from './annotator.vue';
import SequenceLabelingLabelSelector from './sequence_labeling_label_selector.vue';
import HTTP from './http';
import { simpleShortcut } from './filter';

export default {
  filters: { simpleShortcut },

  components: { Annotator, SequenceLabelingLabelSelector },

  mixins: [annotationMixin],

  methods: {
    annotate(labelId) {
      this.$refs.annotator.addLabel(labelId);
    },

    addLabel(annotation) {
      const docId = this.docs[this.pageNumber].id;
      HTTP.post(`docs/${docId}/annotations`, annotation).then((response) => {
        this.annotations[this.pageNumber].push(response.data);
      });
    },

    async submit() {
      const state = this.getState();
      this.url = `docs?q=${this.searchQuery}&seq_annotations__isnull=${state}&offset=${this.offset}`;
      await this.search();
      this.pageNumber = 0;
    },
  },
};
</script>
