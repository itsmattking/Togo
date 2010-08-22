var modifiedFields = {};
function saveBeforeLeaving(e) {
    e = e || window.event;
    var str = 'You have made changes to this item. Are you sure you want to leave before saving?';
    e.returnValue = str;
    return str;
}
function checkForModified(e) {
    e = e || window.event;
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
            listen('beforeunload', window, saveBeforeLeaving);
            return;
        }
    }
    unlisten('beforeunload', window, saveBeforeLeaving);
}

listen('keyup', window, checkForModified);
listen('click', window, checkForModified);
listen('submit', el('edit-form'), function() {
    modifiedFields = {};
    setBeforeLeaving();
});
