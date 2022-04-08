console.log("inside maps.js");

$(function () {
    let map;
    let map_div = document.getElementById("gmap-widget");
    let init_coords = {
        lat: 41.850033,
        lng: -87.6500523,
    };
    initMap(init_coords, map_div);
    let map_info = map_div.dataset;

    for (let building_id of Object.keys(map_info)) {
        let data = JSON.parse(map_info[building_id]);
        let marker = markAddress(data.coordinates);
        buildingInfoWindow(marker, data.info);
    }
});

function initMap(coords, map_div) {
    let initOptions = {
        center: coords,
        zoom: 5,
    };
    map = new google.maps.Map(map_div, initOptions);
}

function markAddress(coords) {
    let marker = new google.maps.Marker({
        position: coords,
        map: map,
    });

    return marker;
}

function buildingInfoWindow(marker, contentString) {
    let infoWindow = new google.maps.InfoWindow({
        content: contentString,
    });

    google.maps.event.addListener(marker, "click", function () {
        infoWindow.open(map, marker);
    });
}
