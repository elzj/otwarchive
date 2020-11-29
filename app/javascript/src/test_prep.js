export default function testPrep() {
  /*
    The autocomplete dropdown for a field (generated by jquery.tokeninput) will only appear
    if the field has focus. The jQuery :focus pseudo-selector returns the focused element
    on the page, but only if the browser itself has focus, and we're running tests in a
    headless browser which is always out of focus.

    We get around this by forcing jQuery to use its own selector engine instead of
    the browser's.

    By Matthew O'Riordan (http://mattheworiordan.com).
    License: IDGAF.

    https://github.com/mattheworiordan/jquery-focus-selenium-webkit-fix
  */

  jQuery.find.selectors.filters.focus = function(elem) {
    const doc = elem.ownerDocument;
    return elem === doc.activeElement && !!(elem.type || elem.href);
  }

  /*
    Disable jQuery animations, because the autocomplete dropdown cannot be
    clicked while it's in the slideDown animation. This causes intermittent
    failures in JavaScript-based autocomplete tests.
  */
  jQuery.fx.off = true;
}
