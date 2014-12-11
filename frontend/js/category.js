$(function () {
  var params = getSearchParameters();
  var parent = (typeof params.parent === 'undefined' || !isNumber(params.parent)) ? 0 : params.parent;
  $.cookie("parent", parent);

  $.post("/chatroom/php/category/breadcrumbtrail.php", {
    parent: parent
  }, function (data) {
    var data = JSON.parse(data);
    $.each(data, function (index) {
      // leaf is index 0
      if (index == -99) {
        createBreadcrumb(data[index].id, data[index].name, false);
      } else {
        createBreadcrumb(data[index].id, data[index].name, true);
      }
    })
  });

  $.post("/chatroom/php/category/listcontents.php", {
    parent: parent
  }, function (data) {
    var data = JSON.parse(data);
    data.reverse();
    $.each(data, function (index) {
      createList($(".current-level"), data[index].id, data[index].name, true, data[index].type);
    })
  });
})

$("#join-conversation").submit(function (event) {
  event.preventDefault();
  var form = $(this);
  $('<input />').attr('type', 'hidden')
          .attr('name', "isPositionA")
          .attr('value', true)
          .appendTo('#join-conversation');
  var data = form.serialize();
  console.log(data);
  var url = "chat.html?id=" + $("#join-conversation > input[name='topic']").val();
  /*$.post(form.attr('action'), data, function () {

  }).done(function () {
    $(location).attr('href', url);
  }).fail(function () {});*/
});

function createBreadcrumb(id, name, enable) {
  if (enable == true) {
    $(".breadcrumb").prepend("<li><a href=category.html?parent=" + id + ">" + name + "</a></li>");
  } else {
    $(".breadcrumb").prepend("<li class=category.html?parent=" + id + ">" + name + "</a></li>");
  }
}

function createList(obj, id, name, enable, type) {
  if (type == "topic") {
    if (enable == true) {
      obj.prepend("<a href=chat.html?id=" + id + " class=\"list-group-item\">" + name + "<span class=\"badge\">" + type + "</span><div class=\"list-group-item-text\"><form id=\"join-conversation\" action=\"/chatroom/php/conversations/createconversation.php\" method=\"post\"><input type=\"hidden\"  name=\"topic\" value=\""+ id +"\"/><div class=\"btn-group\" role=\"group\" aria-label=\"...\"><button type=\"submit\" name=\"side\" value=\"A\" class=\"btn btn-default\">A</button><button type=\"submit\" name=\"side\" value=\"B\" class=\"btn btn-default\">B</button></div></form></div></a>");
    } else {
      obj.prepend("<a href=?chat.html=" + id + " class=\"list-group-item disabled\">" + name + "<span class=\"badge\">" + type + "</span><div class=\"list-group-item-text\"><form action=\"\"><div class=\"btn-group\" role=\"group\" aria-label=\"...\"><button type=\"button\" class=\"btn btn-default\">A</button><button type=\"button\" class=\"btn btn-default\">B</button></div></form></div></a>");
    }
  } else {
    if (enable == true) {
      obj.prepend("<a href=?parent=" + id + " class=\"list-group-item\">" + name + "<span class=\"badge\">" + type + "</span></a>");
    } else {
      obj.prepend("<a href=?parent=" + id + " class=\"list-group-item disabled\">" + name + "<span class=\"badge\">" + type + "</span></a>");
    }
  }
}

function getSearchParameters() {
  var prmstr = window.location.search.substr(1);
  return prmstr != null && prmstr != "" ? transformToAssocArray(prmstr) : {};
}

function transformToAssocArray(prmstr) {
  var params = {};
  var prmarr = prmstr.split("&");
  for (var i = 0; i < prmarr.length; i++) {
    var tmparr = prmarr[i].split("=");
    params[tmparr[0]] = tmparr[1];
  }
  return params;
}

function isNumber(n) {
  return !isNaN(parseFloat(n)) && isFinite(n);
}