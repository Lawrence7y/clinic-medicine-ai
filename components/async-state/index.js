Component({
  properties: {
    mode: {
      type: String,
      value: 'loading'
    },
    title: {
      type: String,
      value: ''
    },
    description: {
      type: String,
      value: ''
    },
    buttonText: {
      type: String,
      value: '重试'
    }
  },

  methods: {
    handleRetry() {
      this.triggerEvent('retry');
    }
  }
});
