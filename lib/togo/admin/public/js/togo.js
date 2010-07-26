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
    this.count = opts.count;
    this.pageCount = Math.ceil(this.count/10);
    this.pageNumber = 1;
    this.relatedIds = {};

    for (var i = 0, len = opts.related_ids.length; i < len; i++) {
        this.relatedIds[opts.related_ids[i]] = true;
    }

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
        MODIFY: 'modify',
        SEARCH: 'search',
        PAGING: 'paging'
    };
};

// Shows/hides all checkboxes table cells, called when 'modify' is clicked
AssociationManager.prototype.toggleCheckboxes = function() {
    var checkboxes = getElementsByClassName('checkbox', this.table),
        func = (this.currentState == this.states.MODIFY) ? addClass : removeClass;
    for (var i = 0, len = checkboxes.length; i < len; i++) {
        func(checkboxes[i],'active');
    }
};

// Adjust the list of related content IDs, called after clicking 'done'
AssociationManager.prototype.adjustRelatedList = function() {
    var selected = [], remove = [];
    for (k in this.relatedIds) {
        if (this.relatedIds[k] == true) {
            selected.push(k);
        } else {
            if (el('selection_' + k)) {
                remove.push(el('selection_' + k).parentNode.parentNode);
            }
        }
    }
    for (var i = 0, len = remove.length; i < len; i++) {
        this.tbody.removeChild(remove[i]);
    }
    getElementsByClassName('related_ids', this.fieldset)[0].value = selected.join(',');
};


AssociationManager.prototype.insertRow = function(data) {
    var out = '<tr><td class="checkbox active">' +
        '<input type="checkbox" value="' + data.id + '" id="selection_' + data.id + '"';
    if (this.relatedIds[data.id]) {
        out += ' checked="checked"';
    }
    out += ' /></td>';
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

// Handles clicking next/previous on paging
AssociationManager.prototype.pagingHandler = function(handler) {
    return function(e) {
        e.preventDefault();
        if (e.target.nodeName == 'A') {
            var direction = e.target.getAttribute('rel') == 'next' ? 1 : -1;
            handler.pageNumber = handler.pageNumber-(direction*-1);
            if (handler.pageNumber <= 0) {
                handler.pageNumber = 1;
            } else if (handler.pageNumber > handler.pageCount) {
                handler.pageNumber = handler.pageCount;
            }
            el('page-number').innerHTML = handler.pageNumber;
            var offset = (handler.pageNumber-1)*10;
            ajax({
                url: "/search/" + handler.model + "?limit=10&offset=" + offset,
                success: handler.searchResultsHandler(handler)
            });
        }
    };
};

// Handles clicks on the table, catching checkbox clicks
AssociationManager.prototype.tableHandler = function(handler) {
    return function(e) {
        if (e.target.getAttribute('type') == 'checkbox') {
            handler.relatedIds[e.target.value] = e.target.checked;
        }
    };
};

// Handlers clicking on the "modify" button on association table
AssociationManager.prototype.modifyHandler = function(handler) {
    return function(e) {
        e.preventDefault();
        switch (handler.currentState) {
          case handler.states.MODIFY:
            handler.modifyButton.innerHTML = 'Modify';
            handler.search.style.display = 'none';
            handler.associatedCount.style.display = 'table-cell';
            handler.currentState = null;
            handler.pageNumber = 1;
            handler.adjustRelatedList();
            break;
        default:
            handler.modifyButton.innerHTML = 'Done';
            handler.search.style.display = 'block';
            handler.associatedCount.style.display = 'none';
            handler.currentState = handler.states.MODIFY;
        }
        handler.toggleCheckboxes();
    };
};

// Handles search results coming back from paging and searching
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

// Handlers search box input
AssociationManager.prototype.searchHandler = function(handler) {
    return function(e) {
        if (e.keyCode == 13) {
            var q = handler.search.getElementsByTagName('input')[0].value;
            var offset = (handler.pageNumber-1)*10;
            if (q > '') {
                ajax({
                    url: "/search/" + handler.model + "?q=" + q + "&limit=10&offset=" + offset,
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