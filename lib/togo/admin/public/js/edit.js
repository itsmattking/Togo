var modifiedFields = {};
function saveBeforeLeaving(e) {
    var str = 'You have made changes to this item. Are you sure you want to leave before saving?';
    e = e || window.event;
    e.returnValue = str;
    return str;
}
function checkForModified(e) {
    var nodeName = e.target.nodeName, type = e.target.getAttribute('type');
    if (!type) { return; }
    var isText = (nodeName == 'INPUT' && type == 'text') || nodeName.match(/TEXTAREA|SELECT/);
    var isToggle = type.match(/checkbox|radio/) != null;
    if (isText || isToggle) {
        var k = e.target.getAttribute('id') || e.target.getAttribute('name');
        modifiedFields[k] = (isToggle || (e.target.value != e.target.defaultValue));
        setBeforeLeaving();
    }
}
function setBeforeLeaving() {
    for (k in modifiedFields) {
        if (modifiedFields[k]) {
            window.onbeforeunload = saveBeforeLeaving;
            return;
        }
    }
    window.onbeforeunload = function() { };
}

listen('keyup', document, checkForModified);
listen('click', document, checkForModified);
listen('submit', el('edit-form'), function() {
    modifiedFields = {};
    setBeforeLeaving();
});
