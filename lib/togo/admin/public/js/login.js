var login = (function() {

    var clearDefaults = function(e) {
        if (this.defaultValue == this.value) {
            removeClass(this, 'placeholder');
            this.value = '';
            if (this.getAttribute('id') == 'password') {
                this.setAttribute('type','password');
            }
        } else if (this.value == '') {
            this.value = this.defaultValue;
            addClass(this, 'placeholder');
            if (this.getAttribute('type') == 'password') {
                this.setAttribute('type', 'text');
            }
        }
    };

    var init = function() {
        listen('focus', el('username'), clearDefaults);
        listen('blur', el('username'), clearDefaults);
        listen('focus', el('password'), clearDefaults);
        listen('blur', el('password'), clearDefaults);
    };

    return {
        init: init
    };

}());