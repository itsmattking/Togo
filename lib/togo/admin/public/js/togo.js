function el(node) {
    return document.getElementById(node);
}

var parseJSON = function(json) {
    if (window.JSON) {
        parseJSON = function(json) {
            return JSON.parse(json);
        };
    } else {
        parseJSON = function(json) {
            return eval("(" + json + ")");
        };
    }
    return parseJSON(json);
};

var ajaxObject = function() {
    if (window.ActiveXObject) {
        ajaxObject = function() {
            return new ActiveXObject('Microsoft.XMLHTTP');
        };
    } else {
        ajaxObject = function() {
            return new XMLHttpRequest();
        };
    }
    return ajaxObject();
}

var ajax = function(opts) {
    var xmlhttp = ajaxObject();
    xmlhttp.onreadystatechange = function() {
        switch (xmlhttp.readyState) {
          case 1:
            if (typeof opts.loading == 'function') { opts.loading(); }
            break;
          case 2:
            if (typeof opts.loaded == 'function') { opts.loaded(); }
            break;
          case 4:
            var res = xmlhttp.responseText;
            switch (xmlhttp.status) {
              case 200: if (typeof opts.success == 'function') { opts.success(res); } break;
              case 404: if (typeof opts.error == 'function') { opts.error(); } break;
              case 500: if (typeof opts.error == 'function') { opts.error(); } break;
            };
            if (typeof opts.complete == 'function') { opts.complete(); }
            break;
        };
    };
    xmlhttp.open((opts.type || 'get').toUpperCase(),opts.url,true);
    xmlhttp.send(null);
};

var listen = function(evnt, elem, func) {
    if (elem.addEventListener) {
        listen = function(evnt, elem, func) {
            elem.addEventListener(evnt,func,false);
        };
    } else if (elem.attachEvent) {
        listen = function(evnt, elem, func) {
            elem.attachEvent('on' + evnt, func);
        };
    }
    listen(evnt,elem,func);
};

var getElementsByClassName = function(classname, el) {
    if (window.getElementsByClassName) {
        getElementsByClassName = function(classname, el) {
            if (!el) { el = document; }
            return el.getElementsByClassName(classname);
        };
    } else {
        getElementsByClassName = function(classname, el) {
            var classElements = new Array();
            if (!el) { el = document; }
            var els = el.getElementsByTagName('*');
            var elsLen = els.length;
            var pattern = new RegExp("(^|\\s)"+classname+"(\\s|$)");
            for (var i = 0, j = 0; i < elsLen; i++) {
                if ( pattern.test(els[i].className) ) {
                    classElements[j] = els[i];
                    j++;
                }
            }
            return classElements;
        };
    }
    return getElementsByClassName(classname, el);
};

var AssociationManager = function(opts) {
    this.name = opts.name;
    this.model = opts.model;
    this.fieldset = el('property-' + this.name);

    this.search = getElementsByClassName('search', this.fieldset)[0];
    listen('keyup',this.search,this.searchHandler(this));

    this.table = this.fieldset.getElementsByTagName('table')[0];
    this.tbody = this.table.getElementsByTagName('tbody')[0];

    listen('click',this.table,this.tableHandler(this));
    this.modifyButton = getElementsByClassName('association-modify', this.table)[0];
    listen('click',this.modifyButton,this.modifyHandler(this));

    this.states = {
        MODIFY: 'modify'
    };
};

AssociationManager.prototype.getCheckboxes = function() {
    return this.table.getElementsByTagName('input');
};

AssociationManager.prototype.toggleCheckboxes = function() {
    var checkboxes = getElementsByClassName('checkbox', this.table),
    display = 'none';
    if (this.currentState == this.states.MODIFY) {
        display = 'table-cell';
    }
    for (var i = 0, len = checkboxes.length; i < len; i++) {
        checkboxes[i].style.display = display;
    }
};

AssociationManager.prototype.adjustRelatedList = function() {
    var checkboxes = this.getCheckboxes(),
        selected = [], remove = [];
    for (var i = 0, len = checkboxes.length; i < len; i++) {
        if (checkboxes[i].checked) {
            selected.push(checkboxes[i].value);
        } else {
            remove.push(checkboxes[i].parentNode.parentNode);
        }
    }
    for (var i = 0, len = remove.length; i < len; i++) {
        this.tbody.removeChild(remove[i]);
    }
    getElementsByClassName('related_ids', this.fieldset)[0].value = selected.join(',');
};

AssociationManager.prototype.insertRow = function(data,fields) {
    var tr = document.createElement('tr');
    tr.innerHTML = '<td class="checkbox">' +
        '<input type="checkbox" value="' + data.id + '" id="selection_' + data.id + '" />' +
        '</td>';
    for (var i = 0, len = fields.length; i < len; i++) {
        tr.innerHTML += '<td>' + data[fields[i]] + '</td>';
    }
    this.tbody.appendChild(tr);
};

AssociationManager.prototype.tableHandler = function(handler) {
    return function(e) {
        if (e.target.getAttribute('type') == 'checkbox') {
        }
    };
};

AssociationManager.prototype.modifyHandler = function(handler) {
    return function(e) {
        e.preventDefault();
        if (handler.currentState == handler.states.MODIFY) {
            handler.modifyButton.innerHTML = 'Modify';
            handler.search.style.display = 'none';
            handler.currentState = null;
            handler.adjustRelatedList();
        } else {
            handler.modifyButton.innerHTML = 'Done';
            handler.search.style.display = 'block';
            handler.currentState = handler.states.MODIFY;
        }
        handler.toggleCheckboxes();
    };
};

AssociationManager.prototype.searchHandler = function(handler) {
    return function(e) {
        e.preventDefault();
        var q = handler.search.getElementsByTagName('input')[0].value;
        ajax({
            url: "/search/" + handler.model + "?q=" + q,
            success: function(data) {
                console.log(data);
                console.log(parseJSON(data));
            }
        });
    };
};