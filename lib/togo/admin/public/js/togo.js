function el(node) {
    return document.getElementById(node);
}

function hasClass(node, name) {
    if (!node || !node.className) { return false; }
    return node.className.split(' ').some(function (n) { return n === name; });
}

function addClass(node, name) {
    if (!node) { return; }
    if (typeof(node.length) == 'undefined') { node = [node]; }
    for (var i = 0; i < node.length; i++) {
        if (!hasClass(node[i], name)) {
            var curClasses = node[i].className.split(' ');
            curClasses.push(name);
            node[i].className = curClasses.join(' ');
        }
    }
};

function removeClass(node, name) {
    if (!node) { return; }
    if (typeof(node.length) == 'undefined') { node = [node]; }
    for (var i = 0; i < node.length; i++) {
        node[i].className = node[i].className.replace(new RegExp("(\\s" + name + ")|(" + name + "\\s)|" + name), "");
    }
}

function toggleClass(node,name) {
    if (hasClass(node,name)) {
        removeClass(node,name);
    } else {
        addClass(node,name);
    }
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
    var req = ajaxObject();
    req.onreadystatechange = function() {
        switch (req.readyState) {
          case 1:
            if (typeof opts.loading == 'function') { opts.loading(); }
            break;
          case 2:
            if (typeof opts.loaded == 'function') { opts.loaded(); }
            break;
          case 4:
            var res = req.responseText;
            switch (req.status) {
              case 200: if (typeof opts.success == 'function') { opts.success(res); } break;
              case 404: if (typeof opts.error == 'function') { opts.error(); } break;
              case 500: if (typeof opts.error == 'function') { opts.error(); } break;
            };
            if (typeof opts.complete == 'function') { opts.complete(); }
            break;
        };
    };
    req.open((opts.type || 'get').toUpperCase(),opts.url,true);
    req.send(null);
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
    if (document.getElementsByClassName) {
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
    this.fields = opts.fields;
    this.relationships = opts.relationships.join(',');

    this.fieldset = el('property-' + this.name);

    this.search = getElementsByClassName('search', this.fieldset)[0];
    listen('keydown',this.search,this.searchHandler(this));

    this.table = this.fieldset.getElementsByTagName('table')[0];
    this.tbody = this.table.getElementsByTagName('tbody')[0];
    this.associatedCount = getElementsByClassName('associated-count',this.table)[0];

    listen('click',this.table,this.tableHandler(this));
    this.modifyButton = getElementsByClassName('association-modify', this.table)[0];
    listen('click',this.modifyButton,this.modifyHandler(this));

    this.paging = getElementsByClassName('paging',this.fieldset)[0];
    listen('click',this.paging,this.pagingHandler(this));

    this.states = {
        MODIFY: 'modify'
    };
};

AssociationManager.prototype.getCheckboxes = function() {
    return this.table.getElementsByTagName('input');
};

AssociationManager.prototype.toggleCheckboxes = function() {
    var checkboxes = getElementsByClassName('checkbox', this.table),
        func = (this.currentState == this.states.MODIFY) ? addClass : removeClass;
    for (var i = 0, len = checkboxes.length; i < len; i++) {
        func(checkboxes[i],'active');
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


AssociationManager.prototype.insertRow = function(data) {
    var out = '<tr><td class="checkbox active">' +
        '<input type="checkbox" value="' + data.id + '" id="selection_' + data.id + '" />' +
        '</td>';
    for (var i = 0, len = this.fields.length; i < len; i++) {
        out += '<td>' + (data[this.fields[i]] == null ? '-' : data[this.fields[i]]) + '</td>';
    }
    out += '</tr>';
    this.tbody.innerHTML += out;
};

AssociationManager.prototype.clearTable = function() {
    while (this.tbody.hasChildNodes()) {
        this.tbody.removeChild(this.tbody.lastChild);
    }
};


AssociationManager.prototype.pagingHandler = function(handler) {
    return function(e) {
        e.preventDefault();
        if (e.target.nodeName == 'A') {
            console.log(e.target.getAttribute('rel'));
        }
    };
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
            handler.associatedCount.style.display = 'table-cell';
            handler.currentState = null;
            handler.adjustRelatedList();
        } else {
            handler.modifyButton.innerHTML = 'Done';
            handler.search.style.display = 'block';
            handler.associatedCount.style.display = 'none';
            handler.currentState = handler.states.MODIFY;
        }
        handler.toggleCheckboxes();
    };
};

AssociationManager.prototype.searchResultsHandler = function(handler) {
    return function(data) {
        data = parseJSON(data);
        handler.clearTable();
        if (data.length > 0) {
            for (var i = 0, len = data.length; i < len; i++) {
                handler.insertRow(data[i]);
            }
        } else {
        }
    };
};

AssociationManager.prototype.searchHandler = function(handler) {
    return function(e) {
        if (e.keyCode == 13) {
            var q = handler.search.getElementsByTagName('input')[0].value;
            if (q > '') {
                ajax({
                    url: "/search/" + handler.model + "?q=" + q + "&r=" + handler.relationships + "&limit=10&offset=0",
                    success: handler.searchResultsHandler(handler)
                });
            } else {
            }
            e.preventDefault();
            return false;
        }
        return true;
    };
};