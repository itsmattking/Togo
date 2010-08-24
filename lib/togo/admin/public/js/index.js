var app = (function() {

    var selectedItems = [];
    var searchInput = el('search-form').getElementsByTagName('input')[0];
    var searchInputDefaultValue = 'Search...';

    var searchInputHandler = function(action) {
        return function(e) {
            e = e || window.event;
            if (this.value == '') {
                this.value = searchInputDefaultValue;
            }
            if (this.value == searchInputDefaultValue && action == 'focus') {
                this.value = '';
            }
        };
    };

    var handleMultiSelect = function(e) {
        e = e || window.event;
        var id = e.target.getAttribute('id').split('_')[1];
        if (e.target.checked) {
            selectedItems.push(id);
        } else {
            for (var i = 0, len = selectedItems.length; i < len; i++) {
                if (selectedItems[i] == id) {
                    selectedItems.splice(i,1);
                    break;
                }
            }
        }
        if (selectedItems.length > 0) {
            el('delete-button').removeAttribute('disabled');
        } else {
            el('delete-button').setAttribute('disabled','disabled');
        }
        el('delete-list').value = selectedItems.join(',');
    };

    listen('focus', searchInput, searchInputHandler('focus'));
    listen('blur', searchInput, searchInputHandler('blur'));

    var c = el('list-table').getElementsByTagName('input');
    for (var i = 0; i < c.length; i++) {
        if (c[i].getAttribute('type') == 'checkbox') {
            listen('click', c[i], handleMultiSelect);
        }
    }

})();
