Component({
  properties: {
    type: {
      type: String,
      value: ''
    },
    theme: {
      type: String,
      value: 'primary'
    },
    variant: {
      type: String,
      value: 'base'
    },
    size: {
      type: String,
      value: 'large'
    },
    block: {
      type: Boolean,
      value: false
    },
    disabled: {
      type: Boolean,
      value: false
    },
    loading: {
      type: Boolean,
      value: false
    },
    shape: {
      type: String,
      value: ''
    }
  },
  methods: {
    handleTap(event) {
      if (this.data.disabled || this.data.loading) {
        return;
      }
      this.triggerEvent('tap', event.detail);
    }
  }
});
