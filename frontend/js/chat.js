function sendMsg() {
  var text = $(".input-group > input").val();
  $(".chatbox").append('<li class = "media"><a class="media-left" href="#"><img src="http://dummyimage.com/64x64/000/fff" alt="..." ></a><div class="media-body"><h4 class="media-heading">Dennis So</h4><div class="md"><p>' + text + '</p></div><ul class="flat-list buttons"><li class="report-button"><a href="javascript:void(0)" class="action-thing" data-action-form="#report-action-form">report</a></li></ul></div></li>');
  $('.chatbox').scrollTop(1E10);
}