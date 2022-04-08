const form = document.getElementById('intervention');
var _hash = window.location.hash;
$("#building").hide();
$("#battery").hide();
$("#column").hide();
$("#elevator").hide();
$("#employee").append('<option value="">None</option>');
$("#building").prop("disabled", true);
$("#customer").change(function () {
    $("#building").show();
    var customer = $(this).val();
    if (customer) {
    $("#building").prop("disabled", false);
    } else 
        {
		 $("#building").prop("disabled", true); 
        }

        $.ajax({
    url: "/intervention/get_building",
    method: "GET",
    dataType: "json",
    data: { customer: customer },
    success: function(response) {
      var buildings = response["buildings"];
      $("#building").empty();
      $("#battery").empty();
      $("#building").append("<option>Select Building</option>");
      $("#battery").append("<option>Select Battery</option>");
      for (var i = 0; i < buildings.length; i++) {
        $("#building").append(
          '<option value="' + buildings[i]["id"] +'">' + buildings[i]["id"]+" </option>"
        );
      }
    }
  });
});
$("#building").change(function() {
  var building = $(this).val();
  if (building) {
    $("#battery").prop("disabled", false);
  } else {
     $("#battery").prop("disabled", true);
  }
  $.ajax({
    url: "/intervention/get_battery",
    method: "GET",
    dataType: "json",
    data: { building: building },
    success: function(response) {
      var batteries = response["batteries"];
      $("#battery").empty();
      $("#battery").append("<option>Select Battery</option>");
      $("#battery").append('<option value="">None</option>');
      for (var i = 0; i < batteries.length; i++) {
        $("#battery").append(
          '<option value="' +
            batteries[i]["id"] +
            '">' +batteries[i]["id"]+" "+
            batteries[i]["typing"] +
            "</option>"
        );
      }
    }
  });
});
$("#battery").change(function() {
  var battery = $(this).val();
  if (battery) {
    $("#column").prop("disabled", false);
  } else {
   $("#column").prop("disabled", true);
  }
  $.ajax({
    url: "/intervention/get_column",
    method: "GET",
    dataType: "json",
    data: {battery: battery},
    success: function(response) {
      var columns = response["columns"];
      $("#column").empty();
      $("#column").append("<option> Select Column </option>");
      $("#column").append('<option value="">None</option>');
      for (var i = 0; i < columns.length; i++) {
        $("#column").append(
          '<option value="' +
            columns[i]["id"] +
            '">' +
            columns[i]["id"] + " "+ columns[i]["typing"]+
            "</option>"
        );
      }
    }
  });
});
$("#column").change(function() {
  var column = $(this).val();
  if (column) {
      $("#elevator").prop("disabled", false);
  } else {
      $("#elevator").prop("disabled", true);
  }
  $.ajax({
    url: "/intervention/get_elevator",
    method: "GET",
    dataType: "json",
    data: { column: column },
    success: function(response) {
      var elevators = response["elevators"];
      $("#elevator").empty();
      $("#elevator").append("<option> Select elevator </option>");
      $("#elevator").append('<option value="">None</option>');
      for (var i = 0; i < elevators.length; i++) {
        $("#elevator").append(
          '<option value="' +
            elevators[i]["id"] +
            '">' +
            elevators[i]["id"] +
            "</option>"
        );
      }
    }
  });
});
$(document).ready(function() {
  var choice = document.getElementById("building");
  choice.addEventListener("change", building);
});
var building = function() {
  var choice = document.getElementById("building").value;
  if (choice) {
    $("#battery").show();
  }
};
// Battery dropDown
$(document).ready(function() {
  var choice = document.getElementById("battery");
  choice.addEventListener("change", battery);
});
var battery = function() {
  var choice = document.getElementById("battery").value;
  if (choice) {
    $("#column").show();
    
  }else if(choice =="") {
    $("#column").hide();
    $("#column").prop("disabled", true);
    $("#elevator").hide();
    $("#elevator").prop("disabled", true);
    }
};
$(document).ready(function() {
  var choice = document.getElementById("column");
  choice.addEventListener("change", column);
});
var column = function() {
  var choice = document.getElementById("column").value;
  if (choice) {
    $("#elevator").show();
  } else if(choice ==""){
    $("#elevator").hide();
    $("#elevator").prop("disabled", true);
  }
};
$(document).ready(function() {
  var choice = document.getElementById("customer");
  choice.addEventListener("change", customer);
});
var customer = function() {
  var choice = document.getElementById("customer").value;
  if (choice) {
    $("#building").show();    
  }
};
jQuery(_hash).show();

