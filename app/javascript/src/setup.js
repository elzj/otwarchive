import $ from 'jquery'
import datepickerFactory from 'jquery-datepicker';
import enableFilters from './filters'

// enable jQuery plugin
datepickerFactory($);

function hideElement(el) {
  el.style.display = 'none';
}

function showElement(el) {
  el.classList.remove('hidden');
  el.style.display = 'block';  
}

function hideElements() {
  document.querySelectorAll('.hideme').forEach(hideElement);
}

function showElements() {
  document.querySelectorAll('.showme').forEach(showElement);
}

// Set up open and close toggles for a given object
// Typical setup (this will leave the toggled item open for users without javascript but hide the controls from them):
// <a class="foo_open hidden">Open Foo</a>
// <div id="foo" class="toggled">
//   foo!
//   <a class="foo_close hidden">Close</a>
// </div>
//
// Notes:
// - The open button CANNOT be inside the toggled div, the close button can be (but doesn't have to be)
// - You can have multiple open and close buttons for the same div since those are labeled with classes
// - You don't have to use div and a, those are just examples. Anything you put the toggled and _open/_close classes on will work.
// - If you want the toggled item not to be visible to users without JavaScript by default, add the class "hidden" to the toggled item as well.
//   (and you can then add an alternative link for them using <noscript>)
// - Generally reserved for toggling complex elements like bookmark forms and challenge sign-ups; for simple elements like lists use setupAccordion.
function setupToggled() {
  document.querySelectorAll('.toggled').forEach(node => {
    const open_toggles = document.querySelectorAll(`.${node.id}_open`);
    const close_toggles = document.querySelectorAll(`.${node.id}_close`);

    if (node.classList.contains('open')) {
      close_toggles.forEach(showElement);
      open_toggles.forEach(hideElement);
    } else {
      hideElement(node);
      close_toggles.forEach(hideElement);
      open_toggles.forEach(showElement);
    }

    open_toggles.forEach(toggler => {
      toggler.addEventListener("click", function(event) {
        event.preventDefault();
        showElement(node);
        open_toggles.forEach(hideElement);
        close_toggles.forEach(showElement);
      });
    });

    close_toggles.forEach(toggler => {
      toggler.addEventListener("click", function(event) {
        event.preventDefault();
        hideElement(node);
        close_toggles.forEach(hideElement);
        open_toggles.forEach(showElement);
      });
    });
  });
}

function toggleFormFields() {
  const togglers = document.querySelectorAll(".toggle_formfield");
  togglers.forEach(toggler => {
    const target = document.getElementById(toggler.id.replace("-show", ""));
    if (toggler.checked) {
      showElement(target);
    } else {
      hideElement(target);
    }

    toggler.addEventListener("click", function(event) {
      if (target.style.display == 'none') {
        showElement(target);
      } else {
        hideElement(target);
        if (target.id != 'chapters-options' && target.id != 'backdate-options') {
          let childFields = target.querySelectorAll("input, textarea, select");
          childFields.forEach(field => {
            let fieldType = field.getAttribute('type');
            if (fieldType == 'checkbox') {
              field.checked = false;
            } else if (fieldType != 'hidden') {
              field.value = '';
            }
          });
        }
      }
      // We want to check this whether the ticky is checked or not
      if (target.id == 'chapters-options') {
        var item = document.getElementById('work_wip_length');
        if (item.value == 1 || item.value == '1') { item.value = '?'; }
        else { item.value = 1; }
      }
    })
  })
}


export default function setup() {
  $('.datepicker').datepicker({
    dateFormat: 'yy-mm-dd'
  });
  setupToggled();
  hideElements();
  showElements();
  enableFilters();
  toggleFormFields();
}