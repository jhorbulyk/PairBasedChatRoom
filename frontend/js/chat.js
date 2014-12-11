$(function () {
  var params = getSearchParameters();
  var id = (typeof params.id === 'undefined' || !isNumber(params.id)) ? 0 : params.id;
  $.cookie("id", id);
  var parent = $.cookie("parent");

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
})

function sendMsg() {
  var text = $(".input-group > input").val();
  $(".chatbox").append('<li class = "media"><a class="media-left" href="#"><img src="http://dummyimage.com/64x64/000/fff" alt="..." ></a><div class="media-body"><h4 class="media-heading">Dennis So</h4><div class="md"><p>' + text + '</p></div><ul class="flat-list buttons"><li class="report-button"><a href="javascript:void(0)" class="action-thing" data-action-form="#report-action-form">report</a></li></ul></div></li>');
  $('.chatbox').scrollTop(1E10);
}

function createBreadcrumb(id, name, enable) {
  if (enable == true) {
    $(".breadcrumb").prepend("<li><a href=category.html?parent=" + id + ">" + name + "</a></li>");
  } else {
    $(".breadcrumb").prepend("<li class=category.html?parent=" + id + ">" + name + "</a></li>");
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