# Windable (v1.0.0)

With working Google Maps example as of 04/01/2020.

Windable is a small (6kb gzipped) configurable library for setting up wind visualizations on your maps.
It can work with any Canvas map layer (Google Maps, Leaflet).
Windable uses WebGL if possible, and canvas as a default. Windable reuses the rendering logic from [earth.nullschool](https://github.com/cambecc/earth/tree/master/public/libs/earth/1.0.0), providing an abstraction to more easily configure your maps. 

The source code is annotated (but not compiled) with ClosureJS style comments.

# Running
For Google Maps, **set APIKEY** in examples/googleMaps/{configurable.html|basic.html}.

## To run locally

```
npm install
grunt app
```
Then browse to http://localhost:5000/ or /google_basic, /leaflet.

## To build and run as a container
```
docker-compose up --build
```
Then browse to http://localhost:5000/ or /google_basic, /leaflet.

# Basic Configuration

WindMap requires you provide a canvas upon which to draw, an extent function that returns the map bounds, and a data object (see [components/wind/typedefs.js](https://github.com/dannycochran/windable/blob/master/components/wind/typedefs.js) for more info).

Configuration with Google Maps would look something like this (see [examples/googleMaps/basic.html](https://github.com/dannycochran/windable/blob/master/examples/googleMaps/basic.html)):

```javascript
const element = document.getElementById('google-map-canvas');

const map = new google.maps.Map(element, {
  zoom: 3,
  center: new google.maps.LatLng(39.3, -45.8)
});

const windMap = new WindMap({
  canvas: new CanvasLayer({map: map}).canvas,
  data: windData // see below for retrieving windData, and examples of data in data/
  extent: () => {
    return {
      width: element.clientWidth,
      height: element.clientHeight,
      latlng:[
        [map.getBounds().getSouthWest().lng(), map.getBounds().getSouthWest().lat()],
        [map.getBounds().getNorthEast().lng(), map.getBounds().getNorthEast().lat()]
      ]
    };
  }
});
```

windMap has three functions: stop, start, and update. Upon initialization, the windMap is started. Subsequent calls to update will clear the rendering canvas and restart the animation with any
new configurations.

To update your windMap with new configurations or data, you can do:

```javascript
windMap.update({
  data: newWindData,
  colorScheme: arrayOfHexColorStrings,
  particuleReduction: 0.1;
});
```

See ConfigPayload in [components/wind/typedefs.js](https://github.com/dannycochran/windable/blob/master/components/wind/typedefs.js) for a list of configurations.

windMap also has a renderer property that exposes information about wind velocity.

To return a mapping of colors to their wind velocity (km / h):

```javascript
windMap.renderer.velocityScale();
```

To return a tuple of [wind direction, wind speed (km /h)] from x,y:

```javascript
canvas.on('click', (e) => {
  windMap.renderer.pointFromXY(e.pageX, e.pageY);
});
```

To return a tuple of [wind direction, wind speed (km /h)] from lat, lng:

```javascript
windMap.renderer.pointFromLatLng(-40, 60);
```

# Wind Data

For dynamic loading, you'd need to do three steps:
 1. Curl data from:

    - http://nomads.ncep.noaa.gov/cgi-bin/filter_gfs_1p00.pl?file=gfs.t00z.pgrb2.1p00.f000&lev_${MILLIBARS}_mb=on&var_UGRD=on&var_VGRD=on&dir=%2Fgfs.${TIMESTAMP}

    - Where TIMESTAMP = YYYYMMDDHH (e.g 2016040106) -- the HH field must be one of: (00, 06, 12, 18) and MILLIBARS is an integer.
    - Continuous integers for millibars aren't supported, see: ftp://ftp.cpc.ncep.noaa.gov/wd51we/ams2010_sc/Obtaining%20data.pdf
    - e.g. curl "http://nomads.ncep.noaa.gov/cgi-bin/filter_gfs_1p00.pl?file=gfs.t00z.pgrb2.1p00.f000&lev_200_mb=on&var_UGRD=on&var_VGRD=on&dir=%2Fgfs.2016041500" -o gfs.t00z.pgrb2.1p00.f000

 2. Convert grib2json using grib2json.

 3. Send back the output json.
