if (!Array.prototype.some)
{
  Array.prototype.some = function(fun /*, thisp*/)
  {
    var len = this.length;
    if (typeof fun != "function")
      throw new TypeError();

    var thisp = arguments[1];
    for (var i = 0; i < len; i++)
    {
      if (i in this &&
          fun.call(thisp, this[i], i, this))
        return true;
    }

    return false;
  };
}
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

var ensureEvent = function(func) {
    return function() {
        var e = window.event;
        e.target = e.srcElement;
        e.preventDefault = function() {
            e.returnValue = false;
        };
        e.stopPropagation = function() {
            e.cancelBubble = true;
        };
        func.call(e.srcElement,e);
    };
};

var listen = function(evnt, elem, func) {
    if (elem.addEventListener) {
        listen = function(evnt, elem, func) {
            elem.addEventListener(evnt,func,false);
        };
    } else if (elem.attachEvent) {
        listen = function(evnt, elem, func) {
            elem.attachEvent('on' + evnt, ensureEvent(func));
        };
    }
    listen(evnt,elem,func);
};

var unlisten = function(evnt, elem, func) {
    if (elem.removeEventListener) {
        unlisten = function(evnt, elem, func) {
            elem.removeEventListener(evnt,func,false);
        };
    } else if (elem.attachEvent) {
        unlisten = function(evnt, elem, func) {
            elem.detachEvent('on' + evnt, ensureEvent(func));
        };
    }
    unlisten(evnt,elem,func);
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
    this.relationship = opts.relationship;
    this.name = opts.name;
    this.model = opts.model;
    this.fields = opts.fields;
    this.count = opts.count;
    this.pageCount = Math.ceil(this.count/10);
    this.pageNumber = 1;
    this.relatedIds = {};
    this.pathPrefix = opts.pathPrefix;

    for (var i = 0, len = opts.related_ids.length; i < len; i++) {
        this.relatedIds[opts.related_ids[i]] = true;
    }

    this.fieldset = el('property-' + this.name);

    this.pageNumberField = getElementsByClassName('page-number',this.fieldset)[0];
    this.pageCountField = getElementsByClassName('page-count',this.fieldset)[0];

    this.search = getElementsByClassName('search', this.fieldset)[0];
    this.searchInput = this.search.getElementsByTagName('input')[0];
    this.defaultSearchValue = this.searchInput.value;

    listen('keydown',this.search,this.searchHandler(this));
    listen('focus', this.searchInput,this.searchInputHandler(this, 'focus'));
    listen('blur', this.searchInput,this.searchInputHandler(this, 'blur'));

    this.table = this.fieldset.getElementsByTagName('table')[0];
    this.tbody = this.table.getElementsByTagName('tbody')[0];
    this.associatedCountDisplay = getElementsByClassName('associated-count-display',this.table)[0];
    this.associatedCount = getElementsByClassName('associated-count',this.table)[0];

    listen('click',this.table,this.tableHandler(this));
    this.modifyButton = getElementsByClassName('association-modify', this.table)[0];
    listen('click',this.modifyButton,this.modifyHandler(this));

    this.paging = getElementsByClassName('paging',this.fieldset)[0];
    listen('click',this.paging,this.pagingHandler(this));

    this.selectorType = this.relationship == 'belongs_to' ? 'radio' : 'checkbox';

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
    var selected = [];
    for (k in this.relatedIds) {
        if (this.relatedIds[k] == true) {
            selected.push(k);
        }
    }
    getElementsByClassName('related_ids', this.fieldset)[0].value = selected.join(',');
    var handler = this;
    ajax({
        url: (this.pathPrefix + "/search/" + this.model + "?ids=" + selected.slice(0,10).join(',')),
        success: function(data) {
            handler.searchResultsHandler(handler)(data);
            handler.count = selected.length;
            if (selected.length < 10) {
                handler.associatedCount.innerHTML = 0;
                handler.associatedCountDisplay.style.display = 'none';
            } else {
                handler.associatedCount.innerHTML = selected.length-10;
                handler.associatedCountDisplay.style.display = 'block';
            }
        }
    });
};

AssociationManager.prototype.setToModifyState = function() {
    ajax({
        url: (this.pathPrefix + "/search/" + this.model),
        success: this.searchResultsHandler(this)
    });
};

AssociationManager.prototype.addLinkToValue = function(id, value, linkIt) {
    if (!linkIt) { return value; }
    return '<a href="' + this.pathPrefix + '/edit/' + this.model + '/' + id + '">' + value + '</a>';
};

AssociationManager.prototype.appendRow = function(data) {
    var tr = this.tbody.insertRow(-1);
    var td = tr.insertCell(-1);
    var cb = '<input type="' + this.selectorType + '" value="' + data.id + '" id="selection_' + this.model + '_' + data.id + '"';
    if (this.relatedIds[data.id]) {
        cb += ' checked="checked"';
    }
    if (this.selectorType == 'radio') {
        cb += ' name="' + this.model + '_' + this.name + '_selection"';
    }
    cb += ' />';
    addClass(td, 'checkbox active');
    td.innerHTML = cb;
    var linkIt = true;
    for (var i = 0, len = this.fields.length; i < len; i++) {
        if (i == 1) { linkIt = false; }
        tr.insertCell(-1).innerHTML = this.addLinkToValue(data.id, (data[this.fields[i]] == null ? '-' : data[this.fields[i]]), linkIt);
    }
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
            var q = '';
            if (handler.searchInput.value != handler.defaultSearchValue) {
                q = handler.searchInput.value;
            }
            var direction = e.target.getAttribute('rel') == 'next' ? 1 : -1;
            handler.pageNumber = handler.pageNumber-(direction*-1);
            if (handler.pageNumber <= 0) {
                handler.pageNumber = 1;
            } else if (handler.pageNumber > handler.pageCount) {
                handler.pageNumber = handler.pageCount;
            }
            handler.pageNumberField.innerHTML = handler.pageNumber;
            var offset = (handler.pageNumber-1)*10;
            ajax({
                url: (handler.pathPrefix + "/search/" + handler.model + "?q=" + q + "&limit=10&offset=" + offset),
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
        if (e.target.getAttribute('type') == 'radio') {
            handler.relatedIds = {};
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
            handler.associatedCountDisplay.style.display = 'table-cell';
            handler.currentState = null;
            handler.pageNumber = 1;
            handler.searchInput.value = handler.defaultSearchValue;
            handler.adjustRelatedList();
            break;
        default:
            handler.modifyButton.innerHTML = 'Done';
            handler.search.style.display = 'block';
            handler.associatedCountDisplay.style.display = 'none';
            handler.currentState = handler.states.MODIFY;
            handler.setToModifyState();
        }
    };
};

// Handles search results coming back from paging and searching
AssociationManager.prototype.searchResultsHandler = function(handler) {
    return function(data) {
        data = parseJSON(data);
        handler.clearTable();
        handler.count = data.count;
        handler.pageCount = Math.ceil(handler.count/10);
        handler.pageCountField.innerHTML = handler.pageCount;
        handler.pageNumberField.innerHTML = handler.pageNumber;
        if (data.results.length > 0) {
            for (var i = 0, len = data.results.length; i < len; i++) {
                handler.appendRow(data.results[i]);
            }
        } else {
        }
        handler.toggleCheckboxes();
    };
};

// Handlers search box input
AssociationManager.prototype.searchHandler = function(handler) {
    return function(e) {
        if (e.keyCode == 13) {
            e.preventDefault();
            var q = handler.searchInput.value;
            handler.pageNumber = 1;
            var offset = (handler.pageNumber-1)*10;
            ajax({
                url: (handler.pathPrefix + "/search/" + handler.model + "?q=" + q + "&limit=10&offset=" + offset),
                success: handler.searchResultsHandler(handler)
            });
            return false;
        }
        return true;
    };
};

AssociationManager.prototype.searchInputHandler = function(handler, action) {
    return function(e) {
        if (this.value == '') {
            this.value = handler.defaultSearchValue;
        }
        if (this.value == handler.defaultSearchValue && action == 'focus') {
            this.value = '';
        }
    };
};

var Togo = (function() {

    var config = {};

    var configure = function(opts) {
        for (k in opts) {
            config[k] = opts[k];
        }
    };

    return {
        config: config,
        configure: configure
    };

}());

