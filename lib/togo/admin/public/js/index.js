var app = (function() {

    var selectedItems = [];

    var handleMultiSelect = function(e) {
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

    var c = el('list-table').getElementsByTagName('input');
    for (var i = 0; i < c.length; i++) {
        if (c[i].getAttribute('type') == 'checkbox') {
            c[i].addEventListener('click', handleMultiSelect, false);
        }
    }

})();
