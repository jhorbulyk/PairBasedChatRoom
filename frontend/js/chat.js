$(function () {
  var params = getSearchParameters();
  var conversation = params.conversation;

  $.post("/chatroom/php/posts/getpostcontent.php", {
    conversation: conversation 
  }, function (data) {
    var data = JSON.parse(data);
    data.reverse();
    $.each(data, function (index) {
      createList($(".chatbox"), data[index].content, data[index].postedByA);
    })
  });
})

function createList(obj, content, postedByA) {
    if (postedByA) {
      obj.prepend("<div" + " class=\"list-group-item\">" + content + "</div>");
    } else {
      obj.prepend("<div" + " class=\"list-group-item disabled\">" + content + "</div>");
    }
}

function sendMsg() {
  var text = $(".input-group > input").val();
  $(".chatbox").append('<li class = "media"><a class="media-left" href="#"><img src="http://dummyimage.com/64x64/000/fff" alt="..." ></a><div class="media-body"><h4 class="media-heading">Dennis So</h4><div class="md"><p>' + text + '</p></div><ul class="flat-list buttons"><li class="report-button"><a href="javascript:void(0)" class="action-thing" data-action-form="#report-action-form">report</a></li></ul></div></li>');
  $('.chatbox').scrollTop(1E10);
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
