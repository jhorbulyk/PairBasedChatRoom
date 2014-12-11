$(function () {
  var hash = window.location.hash;
  hash && $('ul.nav a[href="' + hash + '"]').tab('show');
  var parent = (typeof $.cookie("parent") === 'undefined' || !isNumber($.cookie("parent"))) ? 0 : $.cookie("parent");

  $(".parent").val(parent);

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
});

$("#submit-category").submit(function (event) {
  event.preventDefault();
  var form = $(this);
  var data = form.serialize();
  var url = "category.html?parent=" + $("#submit-category > input[name='parent']").val();
  $.post(form.attr('action'), data, function () {

  }).done(function () {
    $(location).attr('href', url);
  }).fail(function () {});
});

$("#submit-topic").submit(function (event) {
  event.preventDefault();
  var form = $(this);
  var data = form.serialize();
  var url = "chat.html?id=" + $("#submit-topic > input[name='parent']").val();
  $.post(form.attr('action'), data, function () {
  }).done(function () {
    $(location).attr('href', url);
  }).fail(function () {});
});

function createBreadcrumb(id, name, enable) {
  if (enable == true) {
    $(".breadcrumb").prepend("<li><a href=category.html?parent=" + id + ">" + name + "</a></li>");
  } else {
    $(".breadcrumb").prepend("<li class=category.html?parent=" + id + ">" + name + "</a></li>");
  }
}

function isNumber(n) {
  return !isNaN(parseFloat(n)) && isFinite(n);
}