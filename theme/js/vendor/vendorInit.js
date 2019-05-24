(function ( $ ) {
  $( function ( ) {
    $('.wookmark-card-grid > ul').wookmark({
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
  FontAwesomeConfig = { autoAddCss: false };
  renderMathInElement(document.body, {
    delimiters: [
      { left: '\\[', right: '\\]', display: true },
      { left: '\\(', right: '\\)', display: false }
    ]
  });
})();
