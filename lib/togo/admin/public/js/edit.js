var hasModified = false;
function saveBeforeLeaving(e) {
    return 'You have made changes to this item. Are you sure you want to leave before saving?';
}
function checkForModifiedText(e) {
    if ((e.target.nodeName == 'INPUT' && e.target.getAttribute('type') == 'text') ||
        e.target.nodeName == 'TEXTAREA') {
        console.log('modified');
        hasModified = (e.target.value != e.target.defaultValue);
        setBeforeLeaving();
    }
}
function checkForModifiedInputs(e) {
    if (e.target.nodeName == 'SELECT' ||
        (e.target.nodeName == 'INPUT' && e.target.getAttribute('type') == 'checkbox') ||
        (e.target.nodeName == 'INPUT' && e.target.getAttribute('type') == 'radio')) {
        console.log('modified');
        hasModified = true;
        setBeforeLeaving();
    }
}
function setBeforeLeaving() {
    if (hasModified) {
        listen('beforeunload', window, saveBeforeLeaving);
    } else {
        unlisten('beforeunload', window, saveBeforeLeaving);
    }
}

listen('keyup', window, checkForModifiedText);
listen('click', window, checkForModifiedInputs);
listen('submit', el('edit-form'), function() {
    hasModified = false;
    setBeforeLeaving();
});