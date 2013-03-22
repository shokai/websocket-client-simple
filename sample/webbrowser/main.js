var ws = new WebSocket("ws://localhost:8080");

ws.onmessage = function(e){
  print(e.data);
};

ws.onopen = function(e){
  log("websocket open");
  console.log(e);
};

ws.onclose = function(e){
  log("websocket close");
  console.log(e);
};

$(function(){
  $("#btn_post").click(post);
  $("#message").keydown(function(e){
    if(e.keyCode == 13) post();
  });
});

var post = function(){
  var name = $("#name").val();
  var mes = $("#message").val();
  ws.send(name+" : "+mes);
  $("input#message").val("");
};

var log = function(msg){
  console.log(msg);
  $("#chat").prepend($("<li>").text("[log] "+msg));
};

var print = function(msg){
  $("#chat").prepend($("<li>").text(msg));
};
