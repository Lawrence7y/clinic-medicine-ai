const TabMenu = require('./data');
Component({
  data: {
    active: 0,
    list: TabMenu,
  },

  methods: {
    onTabItemTap(e) {
      const index = e.currentTarget.dataset.index;
      this.setData({ active: index });
      wx.switchTab({
        url: this.data.list[index].url.startsWith('/')
          ? this.data.list[index].url
          : `/${this.data.list[index].url}`,
      });
    },

    init() {
      const pages = getCurrentPages();
      const page = pages[pages.length - 1];
      const route = page ? page.route.split('?')[0] : '';
      const active = this.data.list.findIndex(
        (item) =>
          (item.url.startsWith('/') ? item.url.substr(1) : item.url) ===
          `${route}`,
      );
      if (active !== -1) {
        this.setData({ active });
      }
    },
  },
});
