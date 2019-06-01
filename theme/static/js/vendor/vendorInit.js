(function ($) {
  $(function () {
    $('.wookmark-card-grid > ul.full-width-card').wookmark({
      align: 'left',
      autoResize: true,
      container: $('.wookmark-card-grid'),
      itemWidth: "100%",
      flexibleWidth: "100%",
      offset: 12,
      outerOffset: 0,
      ignoreInactiveItems: true,
      resizeDelay: 0,
      fillEmptySpace: false
    });
    $('.wookmark-card-grid > ul.labs-card').wookmark({
      align: 'left',
      autoResize: true,
      container: $('.wookmark-card-grid'),
      itemWidth: 500,
      flexibleWidth: "100%",
      offset: 12,
      outerOffset: 0,
      ignoreInactiveItems: true,
      resizeDelay: 0,
      fillEmptySpace: false
    });
    $('.wookmark-card-grid > ul.assignment-card').wookmark({
      align: 'left',
      autoResize: true,
      container: $('.wookmark-card-grid'),
      itemWidth: 375,
      flexibleWidth: "100%",
      offset: 12,
      outerOffset: 0,
      ignoreInactiveItems: true,
      resizeDelay: 0,
      fillEmptySpace: false
    });
  });
})(jQuery);

(function () {
  hljs.initHighlightingOnLoad();
  FontAwesomeConfig = {
    autoAddCss: false
  };
  renderMathInElement(document.body, {
    delimiters: [{
        left: '\\[',
        right: '\\]',
        display: true
      },
      {
        left: '\\(',
        right: '\\)',
        display: false
      }
    ]
  });
})();
