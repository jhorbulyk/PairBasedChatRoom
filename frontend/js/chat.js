function sendMsg() {
  var text = $(".input-group > input").val();
  $(".chatbox").append('<li class = "media"><a class="media-left" href="#"><img src="http://placehold.it/64x64" alt="..." ></a><div class="media-body"><h4 class="media-heading">Dennis So</h4><div class="md"><p>' + text + '</p></div><ul class="flat-list buttons"><li class="report-button"><a href="javascript:void(0)" class="action-thing" data-action-form="#report-action-form">report</a></li></ul></div></li>');
  $('.chatbox').scrollTop(1E10);
}