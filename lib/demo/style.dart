const maptilerBasicStyle = '''
{
  "version": 8,
  "name": "Basic",
  "center": [0, 0],
  "zoom": 1,
  "bearing": 0,
  "pitch": 0,
  "sources": {
    "maptiler_attribution": {
      "attribution": "<a href=\\"https://www.maptiler.com/copyright/\\" target=\\"_blank\\">&copy; MapTiler</a> <a href=\\"https://www.openstreetmap.org/copyright\\" target=\\"_blank\\">&copy; OpenStreetMap contributors</a>",
      "type": "vector"
    },
    "maptiler_planet": {
      "url": "https://api.maptiler.com/tiles/v3/tiles.json?key={key}",
      "type": "vector"
    }
  },
  "glyphs": "https://api.maptiler.com/fonts/{fontstack}/{range}.pbf?key={key}",
  "layers": [
    {
      "id": "Background",
      "type": "background",
      "layout": {"visibility": "visible"},
      "paint": {
        "background-color": [
          "interpolate",
          ["linear"],
          ["zoom"],
          6,
          "hsl(60,20%,85%)",
          20,
          "hsl(60,24%,90%)"
        ]
      }
    },
    {
      "id": "Residential",
      "type": "fill",
      "source": "maptiler_planet",
      "source-layer": "landuse",
      "maxzoom": 14,
      "filter": [
        "match",
        ["get", "class"],
        ["neighbourhood", "residential", "suburb"],
        true,
        false
      ],
      "layout": {"visibility": "visible"},
      "paint": {
        "fill-color": [
          "interpolate",
          ["linear"],
          ["zoom"],
          2,
          "hsl(60,23%,81%)",
          14,
          "hsl(60,21%,85%)"
        ]
      }
    },
    {
      "id": "Glacier",
      "type": "fill",
      "source": "maptiler_planet",
      "source-layer": "globallandcover",
      "maxzoom": 8,
      "filter": ["==", ["get", "class"], "snow"],
      "layout": {"visibility": "visible"},
      "paint": {"fill-color": "hsla(0,0%,100%,0.7)"}
    },
    {
      "id": "Forest",
      "type": "fill",
      "source": "maptiler_planet",
      "source-layer": "globallandcover",
      "maxzoom": 8,
      "filter": ["match", ["get", "class"], ["forest", "tree"], true, false],
      "layout": {"visibility": "visible"},
      "paint": {
        "fill-color": [
          "interpolate",
          ["linear"],
          ["zoom"],
          1,
          "hsla(91,40%,70%,0.25)",
          7,
          "hsla(91,40%,70%,0.6)"
        ]
      }
    },
    {
      "id": "Sand",
      "type": "fill",
      "source": "maptiler_planet",
      "source-layer": "landcover",
      "minzoom": 8,
      "filter": ["==", ["get", "class"], "sand"],
      "layout": {"visibility": "visible"},
      "paint": {
        "fill-antialias": false,
        "fill-color": "hsla(54,81%,53%,0.3)",
        "fill-opacity": ["interpolate", ["linear"], ["zoom"], 7, 0.7, 12, 1]
      }
    },
    {
      "id": "Grass",
      "type": "fill",
      "source": "maptiler_planet",
      "source-layer": "landcover",
      "minzoom": 8,
      "filter": ["==", ["get", "class"], "grass"],
      "layout": {"visibility": "visible"},
      "paint": {
        "fill-antialias": false,
        "fill-color": "hsla(89,40%,78%,0.8)",
        "fill-opacity": ["interpolate", ["linear"], ["zoom"], 7, 0.7, 12, 1]
      }
    },
    {
      "id": "Wood",
      "type": "fill",
      "source": "maptiler_planet",
      "source-layer": "landcover",
      "minzoom": 8,
      "filter": ["==", ["get", "class"], "wood"],
      "layout": {"visibility": "visible"},
      "paint": {
        "fill-antialias": false,
        "fill-color": "hsla(91,40%,70%,0.8)",
        "fill-opacity": ["interpolate", ["linear"], ["zoom"], 7, 0.7, 12, 1]
      }
    },
    {
      "id": "Water",
      "type": "fill",
      "source": "maptiler_planet",
      "source-layer": "water",
      "filter": ["!=", ["get", "brunnel"], "tunnel"],
      "layout": {"visibility": "visible"},
      "paint": {
        "fill-color": "hsl(205,56%,73%)",
        "fill-opacity": ["match", ["get", "intermittent"], 1, 0.7, 1]
      }
    },
    {
      "id": "River",
      "type": "line",
      "source": "maptiler_planet",
      "source-layer": "waterway",
      "filter": ["!=", ["get", "intermittent"], 1],
      "layout": {"visibility": "visible"},
      "paint": {
        "line-color": "hsl(205,56%,73%)",
        "line-opacity": ["match", ["get", "brunnel"], "tunnel", 0.7, 1],
        "line-width": ["interpolate", ["linear"], ["zoom"], 9, 1, 18, 3]
      }
    },
    {
      "id": "River intermittent",
      "type": "line",
      "source": "maptiler_planet",
      "source-layer": "waterway",
      "filter": ["==", ["get", "intermittent"], 1],
      "layout": {"visibility": "visible"},
      "paint": {
        "line-color": "hsl(205,56%,73%)",
        "line-dasharray": [2, 1],
        "line-opacity": 1,
        "line-width": ["interpolate", ["linear"], ["zoom"], 9, 1, 18, 3]
      }
    },
    {
      "id": "Transit tunnel",
      "type": "line",
      "source": "maptiler_planet",
      "source-layer": "transportation",
      "minzoom": 4,
      "filter": [
        "all",
        ["==", ["get", "brunnel"], "tunnel"],
        ["==", ["get", "class"], "transit"]
      ],
      "layout": {
        "line-cap": "butt",
        "line-join": "miter",
        "visibility": "visible"
      },
      "paint": {
        "line-color": "hsl(34,12%,66%)",
        "line-dasharray": [3, 3],
        "line-opacity": 0.5,
        "line-width": [
          "interpolate",
          ["linear"],
          ["zoom"],
          14,
          0.5,
          16,
          1.2,
          18,
          2
        ]
      }
    },
    {
      "id": "Bridge",
      "type": "fill",
      "source": "maptiler_planet",
      "source-layer": "transportation",
      "filter": [
        "all",
        ["==", ["geometry-type"], "Polygon"],
        ["==", ["get", "brunnel"], "bridge"]
      ],
      "layout": {"visibility": "visible"},
      "paint": {"fill-color": "hsl(47,26%,88%)", "fill-opacity": 0.7}
    },
    {
      "id": "Pier",
      "type": "fill",
      "metadata": {},
      "source": "maptiler_planet",
      "source-layer": "transportation",
      "filter": ["==", ["get", "class"], "pier"],
      "layout": {"visibility": "visible"},
      "paint": {
        "fill-antialias": true,
        "fill-color": "hsl(60,24%,88%)",
        "fill-opacity": 1
      }
    },
    {
      "id": "Road network",
      "type": "line",
      "source": "maptiler_planet",
      "source-layer": "transportation",
      "minzoom": 4,
      "filter": [
        "match",
        ["get", "class"],
        ["bridge", "ferry", "path", "rail", "transit"],
        false,
        true
      ],
      "layout": {
        "line-cap": "round",
        "line-join": "round",
        "visibility": "visible"
      },
      "paint": {
        "line-color": "hsl(0,0%,100%)",
        "line-opacity": ["match", ["get", "brunnel"], "tunnel", 0.5, 1],
        "line-width": [
          "interpolate",
          ["linear", 2],
          ["zoom"],
          4,
          0.5,
          5,
          0.75,
          6,
          1,
          10,
          [
            "match",
            ["get", "class"],
            ["motorway"],
            ["match", ["get", "brunnel"], ["bridge"], 0, 2.5],
            ["trunk"],
            1.5,
            1
          ],
          12,
          [
            "match",
            ["get", "class"],
            ["motorway"],
            ["match", ["get", "ramp"], 1, 1, 4],
            ["trunk"],
            2,
            ["primary"],
            2.5,
            ["secondary", "tertiary"],
            2,
            ["minor"],
            1,
            ["pier", "service", "track"],
            0.5,
            0.5
          ],
          14,
          [
            "match",
            ["get", "class"],
            ["motorway"],
            ["match", ["get", "ramp"], 1, 5, 6],
            ["trunk"],
            3,
            ["primary"],
            5,
            ["secondary"],
            4,
            ["tertiary"],
            3,
            ["minor"],
            2,
            ["pier", "service", "track"],
            1,
            2
          ],
          16,
          [
            "match",
            ["get", "class"],
            ["motorway", "trunk", "primary"],
            8,
            ["secondary"],
            7,
            ["tertiary"],
            6,
            ["minor"],
            4,
            ["pier", "service", "track"],
            2,
            4
          ],
          20,
          [
            "match",
            ["get", "class"],
            ["motorway", "trunk", "primary"],
            28,
            ["secondary"],
            24,
            ["tertiary"],
            20,
            ["minor", "service", "track", "pier"],
            16,
            16
          ]
        ]
      }
    },
    {
      "id": "Path",
      "type": "line",
      "source": "maptiler_planet",
      "source-layer": "transportation",
      "minzoom": 15,
      "filter": ["==", ["get", "class"], "path"],
      "layout": {
        "line-cap": "square",
        "line-join": "bevel",
        "visibility": "visible"
      },
      "paint": {
        "line-color": "hsl(0,0%,100%)",
        "line-dasharray": [1, 1],
        "line-width": [
          "interpolate",
          ["exponential", 1.55],
          ["zoom"],
          15,
          0.5,
          16,
          1,
          18,
          2,
          20,
          3,
          22,
          4
        ]
      }
    },
    {
      "id": "Building",
      "type": "fill",
      "source": "maptiler_planet",
      "source-layer": "building",
      "layout": {"visibility": "visible"},
      "paint": {
        "fill-antialias": true,
        "fill-color": [
          "interpolate",
          ["linear"],
          ["zoom"],
          13,
          "hsl(48,25%,73%)",
          16,
          "hsl(47,32%,77%)"
        ],
        "fill-opacity": 1
      }
    },
    {
      "id": "Railway",
      "type": "line",
      "source": "maptiler_planet",
      "source-layer": "transportation",
      "minzoom": 9,
      "filter": ["==", ["get", "class"], "rail"],
      "layout": {"visibility": "visible"},
      "paint": {
        "line-color": "hsla(33,12%,67%,0.8)",
        "line-opacity": ["match", ["get", "brunnel"], "tunnel", 0.25, 1],
        "line-width": [
          "interpolate",
          ["linear", 1],
          ["zoom"],
          9,
          ["match", ["get", "service"], ["yard", "spur"], 0, 0.5],
          12,
          ["match", ["get", "service"], ["yard", "spur"], 0, 0.6],
          16,
          ["match", ["get", "service"], ["yard", "spur"], 0.75, 2],
          22,
          ["match", ["get", "service"], ["yard", "spur"], 1.5, 3]
        ]
      }
    },
    {
      "id": "Transit",
      "type": "line",
      "source": "maptiler_planet",
      "source-layer": "transportation",
      "filter": [
        "all",
        ["==", ["get", "class"], "transit"],
        ["!=", ["get", "brunnel"], "tunnel"]
      ],
      "layout": {"visibility": "visible"},
      "paint": {
        "line-color": "hsl(34,12%,66%)",
        "line-opacity": 0.5,
        "line-width": [
          "interpolate",
          ["linear"],
          ["zoom"],
          14,
          0.5,
          16,
          1.2,
          18,
          2
        ]
      }
    },
    {
      "id": "Aeroway",
      "type": "line",
      "source": "maptiler_planet",
      "source-layer": "aeroway",
      "minzoom": 10,
      "layout": {
        "line-cap": "round",
        "line-join": "round",
        "visibility": "visible"
      },
      "paint": {
        "line-color": "hsl(0,0%,100%)",
        "line-opacity": 1,
        "line-width": [
          "interpolate",
          ["linear", 2],
          ["zoom"],
          10,
          ["match", ["get", "class"], ["runway"], 1, ["taxiway"], 0.5, 0],
          14,
          ["match", ["get", "class"], ["runway"], 3, ["taxiway"], 2, 0],
          16,
          ["match", ["get", "class"], ["runway"], 10, ["taxiway"], 6, 0]
        ]
      }
    },
    {
      "id": "Airport labels",
      "type": "symbol",
      "source": "maptiler_planet",
      "source-layer": "aerodrome_label",
      "minzoom": 10,
      "filter": ["has", "iata"],
      "layout": {
        "text-anchor": "top",
        "text-field": ["coalesce", ["get", "name:en"], ["get", "name"]],
        "text-font": ["Noto Sans Regular"],
        "text-max-width": 8,
        "text-offset": [0, 0.5],
        "text-size": [
          "interpolate",
          ["linear"],
          ["zoom"],
          10,
          10,
          14,
          12,
          16,
          14
        ],
        "visibility": "visible"
      },
      "paint": {
        "text-color": "hsl(0,0%,12%)",
        "text-halo-blur": 1,
        "text-halo-color": "hsl(0,0%,100%)",
        "text-halo-width": 1.4
      }
    },
    {
      "id": "Station labels",
      "type": "symbol",
      "source": "maptiler_planet",
      "source-layer": "poi",
      "minzoom": 12,
      "filter": [
        "all",
        ["==", ["get", "class"], "railway"],
        ["has", "subclass"]
      ],
      "layout": {
        "text-anchor": "top",
        "text-field": ["coalesce", ["get", "name:en"], ["get", "name"]],
        "text-font": ["Noto Sans Regular"],
        "text-max-width": 8,
        "text-offset": [0, 0.5],
        "text-size": [
          "interpolate",
          ["linear"],
          ["zoom"],
          10,
          10,
          14,
          12,
          16,
          14
        ],
        "visibility": "visible"
      },
      "paint": {
        "text-color": "hsl(0,0%,12%)",
        "text-halo-blur": 1,
        "text-halo-color": "hsl(0,0%,100%)",
        "text-halo-width": 1.4
      }
    },
    {
      "id": "Road labels",
      "type": "symbol",
      "source": "maptiler_planet",
      "source-layer": "transportation_name",
      "minzoom": 14,
      "filter": [
        "all",
        ["==", ["geometry-type"], "LineString"],
        [
          "match",
          ["get", "class"],
          ["aerialway", "ferry", "service"],
          false,
          true
        ]
      ],
      "layout": {
        "symbol-placement": "line",
        "symbol-spacing": [
          "interpolate",
          ["linear"],
          ["zoom"],
          13,
          250,
          20,
          350,
          22,
          600
        ],
        "text-field": ["coalesce", ["get", "name:en"], ["get", "name"]],
        "text-font": ["Noto Sans Regular"],
        "text-letter-spacing": 0.1,
        "text-rotation-alignment": "map",
        "text-size": [
          "interpolate",
          ["exponential", 1.4],
          ["zoom"],
          14,
          8,
          17,
          10,
          20,
          12
        ],
        "text-transform": "uppercase",
        "visibility": "visible"
      },
      "paint": {
        "text-color": "hsl(0,0%,5%)",
        "text-halo-color": "hsl(0,100%,100%)",
        "text-halo-width": 1
      }
    },
    {
      "id": "Other border",
      "type": "line",
      "source": "maptiler_planet",
      "source-layer": "boundary",
      "minzoom": 3,
      "filter": [
        "all",
        [
          "match",
          ["get", "admin_level"],
          [10, 3, 4, 5, 6, 7, 8, 9],
          true,
          false
        ],
        ["==", ["get", "maritime"], 0]
      ],
      "layout": {"visibility": "visible"},
      "paint": {
        "line-color": "hsla(0,0%,60%,0.65)",
        "line-dasharray": [2, 1],
        "line-width": [
          "interpolate",
          ["linear"],
          ["zoom"],
          4,
          0.8,
          11,
          1.75,
          18,
          2.5
        ]
      }
    },
    {
      "id": "Disputed border",
      "type": "line",
      "source": "maptiler_planet",
      "source-layer": "boundary",
      "minzoom": 0,
      "filter": [
        "all",
        ["==", ["get", "admin_level"], 2],
        ["==", ["get", "maritime"], 0],
        ["==", ["get", "disputed"], 1]
      ],
      "layout": {
        "line-cap": "round",
        "line-join": "round",
        "visibility": "visible"
      },
      "paint": {
        "line-color": "hsl(0,0%,64%)",
        "line-dasharray": [2, 2],
        "line-width": ["interpolate", ["linear"], ["zoom"], 1, 1, 5, 1.5, 10, 2]
      }
    },
    {
      "id": "Country border",
      "type": "line",
      "source": "maptiler_planet",
      "source-layer": "boundary",
      "minzoom": 0,
      "filter": [
        "all",
        ["==", ["get", "admin_level"], 2],
        ["==", ["get", "disputed"], 0],
        ["==", ["get", "maritime"], 0]
      ],
      "layout": {
        "line-cap": "round",
        "line-join": "round",
        "visibility": "visible"
      },
      "paint": {
        "line-blur": ["interpolate", ["linear"], ["zoom"], 4, 0.5, 10, 0],
        "line-color": "hsl(0,0%,64%)",
        "line-width": ["interpolate", ["linear"], ["zoom"], 1, 1, 5, 1.5, 10, 2]
      }
    },
    {
      "id": "Place labels",
      "type": "symbol",
      "source": "maptiler_planet",
      "source-layer": "place",
      "minzoom": 0,
      "maxzoom": 16,
      "filter": [
        "match",
        ["get", "class"],
        [
          "hamlet",
          "isolated_dwelling",
          "neighbourhood",
          "province",
          "quarter",
          "suburb",
          "town",
          "village"
        ],
        true,
        false
      ],
      "layout": {
        "symbol-sort-key": ["to-number", ["get", "rank"]],
        "text-field": ["to-string", ["get", "name"]],
        "text-font": ["Noto Sans Regular"],
        "text-max-width": 10,
        "text-size": [
          "interpolate",
          ["linear", 1],
          ["zoom"],
          3,
          11,
          8,
          ["match", ["get", "class"], "city", 15, 13],
          11,
          [
            "match",
            ["get", "class"],
            "city",
            16,
            [
              "suburb",
              "neighbourhood",
              "quarter",
              "hamlet",
              "isolated_dwelling"
            ],
            10,
            13
          ],
          16,
          [
            "match",
            ["get", "class"],
            "city",
            21,
            [
              "suburb",
              "neighbourhood",
              "quarter",
              "hamlet",
              "isolated_dwelling"
            ],
            14,
            16
          ]
        ],
        "visibility": "visible"
      },
      "paint": {
        "text-color": "hsl(0,0%,0%)",
        "text-halo-blur": 0,
        "text-halo-color": "hsla(0,0%,100%,0.75)",
        "text-halo-width": 2
      }
    },
    {
      "id": "City labels",
      "type": "symbol",
      "source": "maptiler_planet",
      "source-layer": "place",
      "maxzoom": 16,
      "filter": ["==", ["get", "class"], "city"],
      "layout": {
        "symbol-sort-key": ["to-number", ["get", "rank"]],
        "text-field": ["to-string", ["get", "name:en"]],
        "text-font": ["Noto Sans Regular"],
        "text-max-width": 10,
        "text-size": [
          "interpolate",
          ["linear", 1],
          ["zoom"],
          3,
          11,
          8,
          15,
          11,
          16,
          16,
          21
        ],
        "visibility": "visible"
      },
      "paint": {
        "text-color": "hsl(0,0%,0%)",
        "text-halo-blur": 0,
        "text-halo-color": "hsla(0,0%,100%,0.75)",
        "text-halo-width": 2
      }
    },
    {
      "id": "Country labels",
      "type": "symbol",
      "source": "maptiler_planet",
      "source-layer": "place",
      "minzoom": 1,
      "maxzoom": 12,
      "filter": [
        "all",
        ["==", ["get", "class"], "country"],
        ["!=", ["get", "iso_a2"], "VA"]
      ],
      "layout": {
        "symbol-sort-key": ["to-number", ["get", "rank"]],
        "text-field": ["to-string", ["get", "name:en"]],
        "text-font": ["Noto Sans Bold"],
        "text-max-width": 8,
        "text-padding": ["interpolate", ["linear"], ["zoom"], 1, 0, 4, 2],
        "text-size": [
          "interpolate",
          ["linear", 1],
          ["zoom"],
          0,
          8,
          1,
          10,
          4,
          ["case", [">", ["get", "rank"], 2], 13, 15],
          8,
          ["case", [">", ["get", "rank"], 2], 18, 22]
        ],
        "visibility": "visible"
      },
      "paint": {
        "text-color": "hsl(0,0%,13%)",
        "text-halo-blur": 1,
        "text-halo-color": "hsla(0,0%,100%,0.75)",
        "text-halo-width": 2
      }
    },
    {
      "id": "Continent labels",
      "type": "symbol",
      "metadata": {},
      "source": "maptiler_planet",
      "source-layer": "place",
      "maxzoom": 1,
      "filter": ["==", ["get", "class"], "continent"],
      "layout": {
        "text-field": ["to-string", ["get", "name:en"]],
        "text-font": ["Noto Sans Bold"],
        "text-justify": "center",
        "text-size": ["interpolate", ["linear"], ["zoom"], 0, 12, 2, 13],
        "text-transform": "uppercase",
        "visibility": "visible"
      },
      "paint": {
        "text-color": "hsl(0,0%,13%)",
        "text-halo-blur": 1,
        "text-halo-color": "hsla(0,0%,100%,0.75)",
        "text-halo-width": 2
      }
    }
  ],
  "id": "basic-v2"
}
''';

const maptilerStreetsStyle = '''
{
  "version": 8,
  "name": "Streets",
  "center": [0, 0],
  "zoom": 1,
  "bearing": 0,
  "pitch": 0,
  "sources": {
    "maptiler_attribution": {
      "attribution": "<a href=\\"https://www.maptiler.com/copyright/\\" target=\\"_blank\\">&copy; MapTiler</a> <a href=\\"https://www.openstreetmap.org/copyright\\" target=\\"_blank\\">&copy; OpenStreetMap contributors</a>",
      "type": "vector"
    },
    "maptiler_planet": {
      "url": "https://api.maptiler.com/tiles/v3/tiles.json?key={key}",
      "type": "vector"
    }
  },
  "sprite": "https://api.maptiler.com/maps/streets-v2/sprite",
  "glyphs": "https://api.maptiler.com/fonts/{fontstack}/{range}.pbf?key={key}",
  "layers": [
    {
      "id": "Background",
      "type": "background",
      "layout": {"visibility": "visible"},
      "paint": {
        "background-color": [
          "interpolate",
          ["linear"],
          ["zoom"],
          6,
          "hsl(47,79%,94%)",
          14,
          "hsl(42,49%,93%)"
        ]
      }
    },
    {
      "id": "Meadow",
      "type": "fill",
      "source": "maptiler_planet",
      "source-layer": "globallandcover",
      "maxzoom": 8,
      "filter": ["==", ["get", "class"], "grass"],
      "layout": {"visibility": "visible"},
      "paint": {
        "fill-antialias": true,
        "fill-color": "hsl(75,51%,85%)",
        "fill-opacity": ["interpolate", ["linear"], ["zoom"], 0, 1, 8, 0.1]
      }
    },
    {
      "id": "Scrub",
      "type": "fill",
      "source": "maptiler_planet",
      "source-layer": "globallandcover",
      "maxzoom": 8,
      "filter": ["==", ["get", "class"], "scrub"],
      "layout": {"visibility": "visible"},
      "paint": {
        "fill-antialias": true,
        "fill-color": "hsl(97,51%,80%)",
        "fill-opacity": ["interpolate", ["linear"], ["zoom"], 0, 1, 8, 0.1]
      }
    },
    {
      "id": "Crop",
      "type": "fill",
      "source": "maptiler_planet",
      "source-layer": "globallandcover",
      "maxzoom": 8,
      "filter": ["==", ["get", "class"], "crop"],
      "layout": {"visibility": "visible"},
      "paint": {
        "fill-antialias": true,
        "fill-color": "hsl(50,67%,86%)",
        "fill-opacity": ["interpolate", ["linear"], ["zoom"], 0, 1, 8, 0.1]
      }
    },
    {
      "id": "Glacier",
      "type": "fill",
      "source": "maptiler_planet",
      "source-layer": "landcover",
      "maxzoom": 24,
      "filter": ["==", ["get", "class"], "ice"],
      "layout": {"visibility": "visible"},
      "paint": {
        "fill-antialias": true,
        "fill-color": "hsl(0,0%,100%)",
        "fill-opacity": ["interpolate", ["linear"], ["zoom"], 0, 1, 10, 0.7]
      }
    },
    {
      "id": "Forest",
      "type": "fill",
      "source": "maptiler_planet",
      "source-layer": "globallandcover",
      "maxzoom": 8,
      "filter": ["match", ["get", "class"], ["forest", "tree"], true, false],
      "layout": {"visibility": "visible"},
      "paint": {
        "fill-antialias": true,
        "fill-color": "hsl(119,38%,76%)",
        "fill-opacity": ["interpolate", ["linear"], ["zoom"], 1, 0.8, 8, 0]
      }
    },
    {
      "id": "Sand",
      "type": "fill",
      "metadata": {},
      "source": "maptiler_planet",
      "source-layer": "landcover",
      "filter": ["==", ["get", "class"], "sand"],
      "layout": {"visibility": "visible"},
      "paint": {
        "fill-antialias": false,
        "fill-color": "hsl(52,93%,89%)",
        "fill-opacity": 0.85
      }
    },
    {
      "id": "Wood",
      "type": "fill",
      "metadata": {},
      "source": "maptiler_planet",
      "source-layer": "landcover",
      "filter": ["==", ["get", "class"], "wood"],
      "layout": {"visibility": "visible"},
      "paint": {"fill-color": "hsl(87,46%,85%)", "fill-opacity": 1}
    },
    {
      "id": "Residential",
      "type": "fill",
      "metadata": {},
      "source": "maptiler_planet",
      "source-layer": "landuse",
      "maxzoom": 24,
      "filter": [
        "match",
        ["get", "class"],
        ["neighbourhood", "residential", "suburbs"],
        true,
        false
      ],
      "layout": {"visibility": "visible"},
      "paint": {
        "fill-color": [
          "interpolate",
          ["linear"],
          ["zoom"],
          4,
          "hsl(44,34%,87%)",
          16,
          "hsl(54,45%,91%)"
        ]
      }
    },
    {
      "id": "Industrial",
      "type": "fill",
      "metadata": {},
      "source": "maptiler_planet",
      "source-layer": "landuse",
      "maxzoom": 24,
      "filter": [
        "match",
        ["get", "class"],
        ["industrial", "quarry"],
        true,
        false
      ],
      "layout": {"visibility": "visible"},
      "paint": {
        "fill-color": [
          "interpolate",
          ["linear"],
          ["zoom"],
          9,
          [
            "match",
            ["get", "class"],
            ["industrial"],
            "hsl(40,67%,90%)",
            "quarry",
            "hsla(32,47%,87%,0.2)",
            "hsl(60,31%,87%)"
          ],
          16,
          [
            "match",
            ["get", "class"],
            ["industrial"],
            "hsl(49,54%,90%)",
            "quarry",
            "hsla(32,47%,87%,0.5)",
            "hsl(60,31%,87%)"
          ]
        ],
        "fill-opacity": [
          "step",
          ["zoom"],
          1,
          9,
          ["match", ["get", "class"], "quarry", 0, 1],
          10,
          1
        ]
      }
    },
    {
      "id": "Grass",
      "type": "fill",
      "metadata": {},
      "source": "maptiler_planet",
      "source-layer": "landcover",
      "filter": ["==", ["get", "class"], "grass"],
      "layout": {"visibility": "visible"},
      "paint": {
        "fill-antialias": false,
        "fill-color": "hsl(103,40%,85%)",
        "fill-opacity": 0.5
      }
    },
    {
      "id": "Airport zone",
      "type": "fill",
      "metadata": {},
      "source": "maptiler_planet",
      "source-layer": "aeroway",
      "minzoom": 11,
      "filter": ["==", ["geometry-type"], "Polygon"],
      "layout": {"visibility": "visible"},
      "paint": {"fill-color": "hsl(0,0%,93%)", "fill-opacity": 1}
    },
    {
      "id": "Pedestrian",
      "type": "fill",
      "metadata": {},
      "source": "maptiler_planet",
      "source-layer": "transportation",
      "filter": [
        "all",
        ["==", ["geometry-type"], "Polygon"],
        ["!", ["has", "brunnel"]],
        ["match", ["get", "class"], ["bridge", "pier"], false, true],
        ["match", ["get", "subclass"], ["pedestrian", "platform"], true, false]
      ],
      "layout": {"visibility": "visible"},
      "paint": {"fill-color": "hsl(43,100%,99%)", "fill-opacity": 0.7}
    },
    {
      "id": "Cemetery",
      "type": "fill",
      "metadata": {},
      "source": "maptiler_planet",
      "source-layer": "landuse",
      "minzoom": 9,
      "filter": ["==", ["get", "class"], "cemetery"],
      "layout": {"visibility": "visible"},
      "paint": {
        "fill-antialias": true,
        "fill-color": "hsl(0,0%,88%)",
        "fill-opacity": ["interpolate", ["linear"], ["zoom"], 9, 0.25, 16, 1]
      }
    },
    {
      "id": "Hospital",
      "type": "fill",
      "metadata": {},
      "source": "maptiler_planet",
      "source-layer": "landuse",
      "minzoom": 9,
      "filter": ["==", ["get", "class"], "hospital"],
      "layout": {"visibility": "visible"},
      "paint": {
        "fill-antialias": true,
        "fill-color": "hsl(12,63%,94%)",
        "fill-opacity": ["interpolate", ["linear"], ["zoom"], 9, 0.25, 16, 1]
      }
    },
    {
      "id": "Stadium",
      "type": "fill",
      "metadata": {},
      "source": "maptiler_planet",
      "source-layer": "landuse",
      "minzoom": 9,
      "filter": [
        "match",
        ["get", "class"],
        ["pitch", "playground", "stadium"],
        true,
        false
      ],
      "layout": {"visibility": "visible"},
      "paint": {
        "fill-antialias": true,
        "fill-color": "hsl(94,100%,88%)",
        "fill-opacity": ["interpolate", ["linear"], ["zoom"], 9, 0.25, 16, 1]
      }
    },
    {
      "id": "School",
      "type": "fill",
      "metadata": {},
      "source": "maptiler_planet",
      "source-layer": "landuse",
      "minzoom": 9,
      "filter": [
        "match",
        ["get", "class"],
        ["college", "school", "university"],
        true,
        false
      ],
      "layout": {"visibility": "visible"},
      "paint": {
        "fill-antialias": true,
        "fill-color": "hsl(194,52%,94%)",
        "fill-opacity": ["interpolate", ["linear"], ["zoom"], 9, 0.25, 16, 1]
      }
    },
    {
      "id": "River tunnel",
      "type": "line",
      "source": "maptiler_planet",
      "source-layer": "waterway",
      "minzoom": 14,
      "filter": ["==", ["get", "brunnel"], "tunnel"],
      "layout": {"line-cap": "round", "visibility": "visible"},
      "paint": {
        "line-color": "hsl(210,73%,78%)",
        "line-dasharray": [2, 4],
        "line-opacity": 0.5,
        "line-width": [
          "interpolate",
          ["exponential", 1.3],
          ["zoom"],
          12,
          0.5,
          20,
          6
        ]
      }
    },
    {
      "id": "River",
      "type": "line",
      "metadata": {},
      "source": "maptiler_planet",
      "source-layer": "waterway",
      "filter": ["!=", ["get", "brunnel"], "tunnel"],
      "layout": {"line-cap": "round", "visibility": "visible"},
      "paint": {
        "line-color": "hsl(210,73%,78%)",
        "line-width": ["interpolate", ["linear"], ["zoom"], 12, 0.5, 20, 6]
      }
    },
    {
      "id": "Water intermittent",
      "type": "fill",
      "metadata": {},
      "source": "maptiler_planet",
      "source-layer": "water",
      "filter": ["==", ["get", "intermittent"], 1],
      "layout": {"visibility": "visible"},
      "paint": {
        "fill-antialias": true,
        "fill-color": "hsl(205,91%,83%)",
        "fill-opacity": 0.85
      }
    },
    {
      "id": "Water",
      "type": "fill",
      "metadata": {},
      "source": "maptiler_planet",
      "source-layer": "water",
      "filter": ["!=", ["get", "intermittent"], 1],
      "layout": {"visibility": "visible"},
      "paint": {
        "fill-antialias": true,
        "fill-color": "hsl(204,92%,75%)",
        "fill-opacity": ["match", ["get", "intermittent"], 1, 0.85, 1]
      }
    },
    {
      "id": "Aeroway",
      "type": "line",
      "metadata": {},
      "source": "maptiler_planet",
      "source-layer": "aeroway",
      "minzoom": 11,
      "layout": {"visibility": "visible"},
      "paint": {
        "line-color": "hsl(0,0%,100%)",
        "line-width": [
          "interpolate",
          ["linear", 1],
          ["zoom"],
          11,
          ["match", ["get", "class"], ["runway"], 3, 0.5],
          20,
          ["match", ["get", "class"], ["runway"], 16, 6]
        ]
      }
    },
    {
      "id": "Heliport",
      "type": "fill",
      "metadata": {},
      "source": "maptiler_planet",
      "source-layer": "aeroway",
      "minzoom": 11,
      "filter": [
        "match",
        ["get", "class"],
        ["helipad", "heliport"],
        true,
        false
      ],
      "layout": {"visibility": "visible"},
      "paint": {"fill-color": "hsl(0,0%,100%)", "fill-opacity": 1}
    },
    {
      "id": "Ferry line",
      "type": "line",
      "source": "maptiler_planet",
      "source-layer": "transportation",
      "minzoom": 6,
      "filter": ["==", ["get", "class"], "ferry"],
      "layout": {"line-join": "round", "visibility": "visible"},
      "paint": {
        "line-color": [
          "interpolate",
          ["linear"],
          ["zoom"],
          10,
          "hsl(205,61%,63%)",
          16,
          "hsl(205,67%,47%)"
        ],
        "line-dasharray": [2, 2],
        "line-opacity": [
          "interpolate",
          ["linear"],
          ["zoom"],
          6,
          0.5,
          7,
          0.8,
          8,
          1
        ],
        "line-width": ["interpolate", ["linear"], ["zoom"], 10, 0.5, 14, 1.1]
      }
    },
    {
      "id": "Tunnel outline",
      "type": "line",
      "metadata": {},
      "source": "maptiler_planet",
      "source-layer": "transportation",
      "minzoom": 4,
      "filter": [
        "all",
        ["==", ["get", "brunnel"], "tunnel"],
        [
          "match",
          ["get", "class"],
          [
            "aerialway",
            "bridge",
            "ferry",
            "minor_construction",
            "motorway_construction",
            "path",
            "pier",
            "primary_construction",
            "rail",
            "secondary_construction",
            "service_construction",
            "tertiary_construction",
            "track_construction",
            "transit",
            "trunk_construction"
          ],
          false,
          true
        ]
      ],
      "layout": {
        "line-cap": "butt",
        "line-join": "round",
        "visibility": "visible"
      },
      "paint": {
        "line-color": [
          "match",
          ["get", "class"],
          "motorway",
          "hsl(28,72%,69%)",
          ["trunk", "primary"],
          "hsl(28,72%,69%)",
          "hsl(36,5%,80%)"
        ],
        "line-dasharray": [0.5, 0.25],
        "line-width": [
          "interpolate",
          ["linear", 2],
          ["zoom"],
          6,
          0,
          7,
          0.5,
          10,
          [
            "match",
            ["get", "class"],
            ["motorway"],
            ["match", ["get", "ramp"], 1, 0, 2.5],
            ["trunk", "primary"],
            2,
            0
          ],
          12,
          [
            "match",
            ["get", "class"],
            ["motorway"],
            ["match", ["get", "ramp"], 1, 2, 6],
            ["trunk", "primary"],
            3,
            ["secondary", "tertiary"],
            2,
            ["minor", "service", "track"],
            1,
            0.5
          ],
          14,
          [
            "match",
            ["get", "class"],
            ["motorway"],
            ["match", ["get", "ramp"], 1, 5, 8],
            ["trunk"],
            4,
            ["primary"],
            6,
            ["secondary"],
            6,
            ["tertiary"],
            4,
            ["minor", "service", "track"],
            3,
            3
          ],
          16,
          [
            "match",
            ["get", "class"],
            ["motorway", "trunk", "primary"],
            10,
            ["secondary"],
            8,
            ["tertiary"],
            8,
            ["minor", "service", "track"],
            4,
            4
          ],
          20,
          [
            "match",
            ["get", "class"],
            ["motorway", "trunk", "primary"],
            26,
            ["secondary"],
            26,
            ["tertiary"],
            26,
            ["minor", "service", "track"],
            18,
            18
          ]
        ]
      }
    },
    {
      "id": "Tunnel",
      "type": "line",
      "metadata": {},
      "source": "maptiler_planet",
      "source-layer": "transportation",
      "minzoom": 4,
      "filter": [
        "all",
        ["==", ["get", "brunnel"], "tunnel"],
        [
          "match",
          ["get", "class"],
          [
            "aerialway",
            "bridge",
            "ferry",
            "minor_construction",
            "motorway_construction",
            "path",
            "pier",
            "primary_construction",
            "rail",
            "secondary_construction",
            "service_construction",
            "tertiary_construction",
            "track_construction",
            "transit",
            "trunk_construction"
          ],
          false,
          true
        ]
      ],
      "layout": {
        "line-cap": "butt",
        "line-join": "round",
        "visibility": "visible"
      },
      "paint": {
        "line-color": [
          "match",
          ["get", "class"],
          "motorway",
          "hsl(35,100%,76%)",
          ["trunk", "primary"],
          "hsl(48,100%,88%)",
          "hsl(0,0%,96%)"
        ],
        "line-opacity": 1,
        "line-width": [
          "interpolate",
          ["linear", 2],
          ["zoom"],
          5,
          0,
          6,
          [
            "match",
            ["get", "class"],
            ["motorway"],
            ["match", ["get", "brunnel"], ["bridge"], 0, 1],
            ["trunk", "primary"],
            0,
            0
          ],
          10,
          [
            "match",
            ["get", "class"],
            ["motorway"],
            ["match", ["get", "ramp"], 1, 0, 2.5],
            ["trunk", "primary"],
            1.5,
            1
          ],
          12,
          [
            "match",
            ["get", "class"],
            ["motorway"],
            ["match", ["get", "ramp"], 1, 1, 4],
            ["trunk"],
            2.5,
            ["primary"],
            2.5,
            ["secondary", "tertiary"],
            1.5,
            ["minor", "service", "track"],
            1,
            1
          ],
          14,
          [
            "match",
            ["get", "class"],
            ["motorway"],
            ["match", ["get", "ramp"], 1, 5, 6],
            ["trunk"],
            3,
            ["primary"],
            5,
            ["secondary"],
            4,
            ["tertiary"],
            3,
            ["minor", "service", "track"],
            2,
            2
          ],
          16,
          [
            "match",
            ["get", "class"],
            ["motorway", "trunk", "primary"],
            8,
            ["secondary"],
            7,
            ["tertiary"],
            6,
            ["minor", "service", "track"],
            4,
            4
          ],
          20,
          [
            "match",
            ["get", "class"],
            ["motorway", "trunk", "primary"],
            24,
            ["secondary"],
            24,
            ["tertiary"],
            24,
            ["minor", "service", "track"],
            16,
            16
          ]
        ]
      }
    },
    {
      "id": "Railway tunnel",
      "type": "line",
      "metadata": {},
      "source": "maptiler_planet",
      "source-layer": "transportation",
      "filter": [
        "all",
        ["==", ["get", "brunnel"], "tunnel"],
        ["==", ["get", "class"], "rail"]
      ],
      "layout": {"visibility": "visible"},
      "paint": {
        "line-color": "hsl(0,0%,73%)",
        "line-opacity": 0.5,
        "line-width": [
          "interpolate",
          ["exponential", 1.4],
          ["zoom"],
          14,
          0.4,
          15,
          0.75,
          20,
          2
        ]
      }
    },
    {
      "id": "Railway tunnel hatching",
      "type": "line",
      "metadata": {},
      "source": "maptiler_planet",
      "source-layer": "transportation",
      "filter": [
        "all",
        ["==", ["get", "brunnel"], "tunnel"],
        ["==", ["get", "class"], "rail"]
      ],
      "layout": {"visibility": "visible"},
      "paint": {
        "line-color": "hsl(0,0%,73%)",
        "line-dasharray": [0.2, 8],
        "line-opacity": 0.5,
        "line-width": [
          "interpolate",
          ["exponential", 1.4],
          ["zoom"],
          14.5,
          0,
          15,
          3,
          20,
          8
        ]
      }
    },
    {
      "id": "Footway tunnel outline",
      "type": "line",
      "metadata": {},
      "source": "maptiler_planet",
      "source-layer": "transportation",
      "minzoom": 12,
      "filter": [
        "all",
        ["==", ["geometry-type"], "LineString"],
        ["match", ["get", "class"], ["path", "pedestrian"], true, false],
        ["==", ["get", "brunnel"], "tunnel"]
      ],
      "layout": {
        "line-cap": "round",
        "line-join": "miter",
        "visibility": "visible"
      },
      "paint": {
        "line-color": "hsl(0,0%,100%)",
        "line-opacity": 1,
        "line-width": [
          "interpolate",
          ["exponential", 1.2],
          ["zoom"],
          14,
          0,
          16,
          0,
          18,
          4,
          22,
          8
        ]
      }
    },
    {
      "id": "Footway tunnel",
      "type": "line",
      "metadata": {},
      "source": "maptiler_planet",
      "source-layer": "transportation",
      "minzoom": 12,
      "filter": [
        "all",
        ["==", ["geometry-type"], "LineString"],
        ["match", ["get", "class"], ["path", "pedestrian"], true, false],
        ["==", ["get", "brunnel"], "tunnel"]
      ],
      "layout": {
        "line-cap": "butt",
        "line-join": "round",
        "visibility": "visible"
      },
      "paint": {
        "line-color": "hsl(0,0%,63%)",
        "line-dasharray": [
          "step",
          ["zoom"],
          ["literal", [1, 0.5]],
          18,
          ["literal", [1, 0.25]]
        ],
        "line-opacity": 0.4,
        "line-width": [
          "interpolate",
          ["exponential", 1.2],
          ["zoom"],
          14,
          0.5,
          16,
          1,
          18,
          2,
          22,
          5
        ]
      }
    },
    {
      "id": "Pier",
      "type": "fill",
      "metadata": {},
      "source": "maptiler_planet",
      "source-layer": "transportation",
      "filter": [
        "all",
        ["==", ["geometry-type"], "Polygon"],
        ["==", ["get", "class"], "pier"]
      ],
      "layout": {"visibility": "visible"},
      "paint": {"fill-antialias": true, "fill-color": "hsl(42,49%,93%)"}
    },
    {
      "id": "Pier road",
      "type": "line",
      "metadata": {},
      "source": "maptiler_planet",
      "source-layer": "transportation",
      "filter": [
        "all",
        ["==", ["geometry-type"], "LineString"],
        ["==", ["get", "class"], "pier"]
      ],
      "layout": {
        "line-cap": "round",
        "line-join": "round",
        "visibility": "visible"
      },
      "paint": {
        "line-color": "hsl(42,49%,93%)",
        "line-width": [
          "interpolate",
          ["exponential", 1.2],
          ["zoom"],
          15,
          1,
          17,
          4
        ]
      }
    },
    {
      "id": "Bridge",
      "type": "fill",
      "metadata": {},
      "source": "maptiler_planet",
      "source-layer": "transportation",
      "filter": [
        "all",
        ["==", ["geometry-type"], "Polygon"],
        ["==", ["get", "brunnel"], "bridge"]
      ],
      "layout": {"visibility": "visible"},
      "paint": {
        "fill-antialias": true,
        "fill-color": "hsl(42,49%,93%)",
        "fill-opacity": 0.6
      }
    },
    {
      "id": "Minor road outline",
      "type": "line",
      "metadata": {},
      "source": "maptiler_planet",
      "source-layer": "transportation",
      "minzoom": 4,
      "filter": [
        "all",
        ["!=", ["get", "brunnel"], "tunnel"],
        [
          "match",
          ["get", "class"],
          [
            "aerialway",
            "bridge",
            "ferry",
            "minor_construction",
            "motorway",
            "motorway_construction",
            "path",
            "path_construction",
            "pier",
            "primary",
            "primary_construction",
            "rail",
            "secondary_construction",
            "service_construction",
            "tertiary_construction",
            "track_construction",
            "transit",
            "trunk_construction"
          ],
          false,
          true
        ]
      ],
      "layout": {
        "line-cap": "butt",
        "line-join": "round",
        "visibility": "visible"
      },
      "paint": {
        "line-color": "hsl(36,5%,80%)",
        "line-opacity": 1,
        "line-width": [
          "interpolate",
          ["linear", 2],
          ["zoom"],
          6,
          0,
          7,
          0.5,
          12,
          [
            "match",
            ["get", "class"],
            ["secondary", "tertiary"],
            2,
            ["minor", "service", "track"],
            1,
            0.5
          ],
          14,
          [
            "match",
            ["get", "class"],
            ["secondary"],
            6,
            ["tertiary"],
            4,
            ["minor", "service", "track"],
            3,
            3
          ],
          16,
          [
            "match",
            ["get", "class"],
            ["secondary"],
            8,
            ["tertiary"],
            8,
            ["minor", "service", "track"],
            4,
            4
          ],
          20,
          [
            "match",
            ["get", "class"],
            ["secondary"],
            26,
            ["tertiary"],
            26,
            ["minor", "service", "track"],
            18,
            18
          ]
        ]
      }
    },
    {
      "id": "Major road outline",
      "type": "line",
      "metadata": {},
      "source": "maptiler_planet",
      "source-layer": "transportation",
      "minzoom": 4,
      "filter": [
        "all",
        ["!=", ["get", "brunnel"], "tunnel"],
        ["match", ["get", "class"], ["primary", "trunk"], true, false]
      ],
      "layout": {
        "line-cap": "butt",
        "line-join": "round",
        "visibility": "visible"
      },
      "paint": {
        "line-color": "hsl(28,72%,69%)",
        "line-opacity": 1,
        "line-width": [
          "interpolate",
          ["linear", 2],
          ["zoom"],
          6,
          0,
          7,
          0.5,
          10,
          ["match", ["get", "class"], ["trunk", "primary"], 2.4, 0],
          12,
          ["match", ["get", "class"], ["trunk", "primary"], 3, 0.5],
          14,
          ["match", ["get", "class"], ["trunk"], 4, ["primary"], 6, 3],
          16,
          ["match", ["get", "class"], ["trunk", "primary"], 10, 4],
          20,
          ["match", ["get", "class"], ["trunk", "primary"], 26, 18]
        ]
      }
    },
    {
      "id": "Highway outline",
      "type": "line",
      "metadata": {},
      "source": "maptiler_planet",
      "source-layer": "transportation",
      "minzoom": 4,
      "filter": [
        "all",
        ["!=", ["get", "brunnel"], "tunnel"],
        ["==", ["get", "class"], "motorway"]
      ],
      "layout": {
        "line-cap": "butt",
        "line-join": "round",
        "visibility": "visible"
      },
      "paint": {
        "line-color": "hsl(28,72%,69%)",
        "line-opacity": 1,
        "line-width": [
          "interpolate",
          ["linear", 2],
          ["zoom"],
          6,
          0,
          7,
          0.5,
          10,
          [
            "match",
            ["get", "class"],
            ["motorway"],
            ["match", ["get", "ramp"], 1, 0, 2.5],
            0
          ],
          12,
          [
            "match",
            ["get", "class"],
            ["motorway"],
            ["match", ["get", "ramp"], 1, 2, 6],
            0.5
          ],
          14,
          [
            "match",
            ["get", "class"],
            ["motorway"],
            ["match", ["get", "ramp"], 1, 5, 8],
            3
          ],
          16,
          ["match", ["get", "class"], ["motorway"], 10, 4],
          20,
          ["match", ["get", "class"], ["motorway"], 26, 18]
        ]
      }
    },
    {
      "id": "Road under construction",
      "type": "line",
      "metadata": {},
      "source": "maptiler_planet",
      "source-layer": "transportation",
      "minzoom": 4,
      "filter": [
        "match",
        ["get", "class"],
        [
          "minor_construction",
          "motorway_construction",
          "primary_construction",
          "secondary_construction",
          "service_construction",
          "tertiary_construction",
          "track_construction",
          "trunk_construction"
        ],
        true,
        false
      ],
      "layout": {
        "line-cap": "square",
        "line-join": "round",
        "visibility": "visible"
      },
      "paint": {
        "line-color": [
          "match",
          ["get", "class"],
          "motorway_construction",
          "hsl(35,100%,76%)",
          ["trunk_construction", "primary_construction"],
          "hsl(48,100%,83%)",
          "hsl(0,0%,100%)"
        ],
        "line-dasharray": [2, 2],
        "line-opacity": ["case", ["==", ["get", "brunnel"], "tunnel"], 0.7, 1],
        "line-width": [
          "interpolate",
          ["linear", 2],
          ["zoom"],
          5,
          [
            "match",
            ["get", "class"],
            ["motorway_construction"],
            ["match", ["get", "brunnel"], ["bridge"], 0, 0.5],
            ["trunk_construction", "primary_construction"],
            0,
            0
          ],
          10,
          [
            "match",
            ["get", "class"],
            ["motorway_construction"],
            ["match", ["get", "ramp"], 1, 0, 2.5],
            ["trunk_construction", "primary_construction"],
            1.5,
            1
          ],
          12,
          [
            "match",
            ["get", "class"],
            ["motorway_construction"],
            ["match", ["get", "ramp"], 1, 1, 4],
            ["trunk_construction"],
            2.5,
            ["primary_construction"],
            2.5,
            ["secondary_construction", "tertiary_construction"],
            1.5,
            [
              "minor_construction",
              "service_construction",
              "track_construction"
            ],
            1,
            1
          ],
          14,
          [
            "match",
            ["get", "class"],
            ["motorway_construction"],
            ["match", ["get", "ramp"], 1, 5, 6],
            ["trunk_construction"],
            3,
            ["primary_construction"],
            5,
            ["secondary_construction"],
            4,
            ["tertiary_construction"],
            3,
            [
              "minor_construction",
              "service_construction",
              "track_construction"
            ],
            2,
            2
          ],
          16,
          [
            "match",
            ["get", "class"],
            [
              "motorway_construction",
              "trunk_construction",
              "primary_construction"
            ],
            8,
            ["secondary_construction"],
            7,
            ["tertiary_construction"],
            6,
            [
              "minor_construction",
              "service_construction",
              "track_construction"
            ],
            4,
            4
          ],
          20,
          [
            "match",
            ["get", "class"],
            [
              "motorway_construction",
              "trunk_construction",
              "primary_construction"
            ],
            24,
            ["secondary_construction"],
            24,
            ["tertiary_construction"],
            24,
            [
              "minor_construction",
              "service_construction",
              "track_construction"
            ],
            16,
            16
          ]
        ]
      }
    },
    {
      "id": "Minor road",
      "type": "line",
      "metadata": {},
      "source": "maptiler_planet",
      "source-layer": "transportation",
      "minzoom": 4,
      "filter": [
        "all",
        ["!=", ["get", "brunnel"], "tunnel"],
        [
          "match",
          ["get", "class"],
          [
            "aerialway",
            "bridge",
            "ferry",
            "minor_construction",
            "motorway",
            "motorway_construction",
            "path",
            "path_construction",
            "pier",
            "primary",
            "primary_construction",
            "rail",
            "secondary_construction",
            "service_construction",
            "tertiary_construction",
            "track_construction",
            "transit",
            "trunk_construction"
          ],
          false,
          true
        ]
      ],
      "layout": {
        "line-cap": "butt",
        "line-join": "round",
        "visibility": "visible"
      },
      "paint": {
        "line-color": "hsl(0,0%,100%)",
        "line-width": [
          "interpolate",
          ["linear", 2],
          ["zoom"],
          5,
          0.5,
          10,
          1,
          12,
          [
            "match",
            ["get", "class"],
            ["secondary", "tertiary"],
            1.5,
            ["minor", "service", "track"],
            1,
            1
          ],
          14,
          [
            "match",
            ["get", "class"],
            ["secondary"],
            4,
            ["tertiary"],
            3,
            ["minor", "service", "track"],
            2,
            2
          ],
          16,
          [
            "match",
            ["get", "class"],
            ["secondary"],
            7,
            ["tertiary"],
            6,
            ["minor", "service", "track"],
            4,
            4
          ],
          20,
          [
            "match",
            ["get", "class"],
            ["secondary"],
            24,
            ["tertiary"],
            24,
            ["minor", "service", "track"],
            16,
            16
          ]
        ]
      }
    },
    {
      "id": "Major road",
      "type": "line",
      "metadata": {},
      "source": "maptiler_planet",
      "source-layer": "transportation",
      "minzoom": 4,
      "filter": [
        "all",
        ["!=", ["get", "brunnel"], "tunnel"],
        ["match", ["get", "class"], ["primary", "trunk"], true, false]
      ],
      "layout": {
        "line-cap": "butt",
        "line-join": "round",
        "visibility": "visible"
      },
      "paint": {
        "line-color": "hsl(48,100%,83%)",
        "line-width": [
          "interpolate",
          ["linear", 2],
          ["zoom"],
          10,
          ["match", ["get", "class"], ["trunk", "primary"], 1.5, 1],
          12,
          ["match", ["get", "class"], ["trunk", "primary"], 2.5, 1],
          14,
          ["match", ["get", "class"], ["trunk"], 3, ["primary"], 5, 2],
          16,
          ["match", ["get", "class"], ["trunk", "primary"], 8, 4],
          20,
          ["match", ["get", "class"], ["trunk", "primary"], 24, 16]
        ]
      }
    },
    {
      "id": "Highway",
      "type": "line",
      "metadata": {},
      "source": "maptiler_planet",
      "source-layer": "transportation",
      "minzoom": 4,
      "filter": [
        "all",
        ["!=", ["get", "brunnel"], "tunnel"],
        ["==", ["get", "class"], "motorway"]
      ],
      "layout": {
        "line-cap": "butt",
        "line-join": "round",
        "visibility": "visible"
      },
      "paint": {
        "line-color": "hsl(35,100%,76%)",
        "line-width": [
          "interpolate",
          ["linear", 2],
          ["zoom"],
          5,
          0.5,
          6,
          [
            "match",
            ["get", "class"],
            ["motorway"],
            ["match", ["get", "brunnel"], ["bridge"], 0, 1],
            0
          ],
          10,
          [
            "match",
            ["get", "class"],
            ["motorway"],
            ["match", ["get", "ramp"], 1, 0, 2.5],
            1
          ],
          12,
          [
            "match",
            ["get", "class"],
            ["motorway"],
            ["match", ["get", "ramp"], 1, 1, 4],
            1
          ],
          14,
          [
            "match",
            ["get", "class"],
            ["motorway"],
            ["match", ["get", "ramp"], 1, 5, 6],
            2
          ],
          16,
          ["match", ["get", "class"], ["motorway"], 8, 4],
          20,
          ["match", ["get", "class"], ["motorway"], 24, 16]
        ]
      }
    },
    {
      "id": "Path outline",
      "type": "line",
      "metadata": {},
      "source": "maptiler_planet",
      "source-layer": "transportation",
      "minzoom": 12,
      "filter": [
        "all",
        ["==", ["geometry-type"], "LineString"],
        ["match", ["get", "class"], ["path", "pedestrian"], true, false],
        ["!=", ["get", "brunnel"], "tunnel"]
      ],
      "layout": {
        "line-cap": "round",
        "line-join": "miter",
        "visibility": "visible"
      },
      "paint": {
        "line-color": "hsl(0,0%,100%)",
        "line-width": [
          "interpolate",
          ["exponential", 1.2],
          ["zoom"],
          14,
          0,
          16,
          0,
          18,
          4,
          22,
          8
        ]
      }
    },
    {
      "id": "Path",
      "type": "line",
      "metadata": {},
      "source": "maptiler_planet",
      "source-layer": "transportation",
      "minzoom": 12,
      "filter": [
        "all",
        ["==", ["geometry-type"], "LineString"],
        ["match", ["get", "class"], ["path", "pedestrian"], true, false],
        ["!=", ["get", "brunnel"], "tunnel"]
      ],
      "layout": {
        "line-cap": "butt",
        "line-join": "round",
        "visibility": "visible"
      },
      "paint": {
        "line-color": "hsl(0,0%,79%)",
        "line-dasharray": [
          "step",
          ["zoom"],
          ["literal", [1, 0.5]],
          18,
          ["literal", [1, 0.25]]
        ],
        "line-width": [
          "interpolate",
          ["exponential", 1.2],
          ["zoom"],
          14,
          0.5,
          16,
          1,
          18,
          2,
          22,
          5
        ]
      }
    },
    {
      "id": "Major rail",
      "type": "line",
      "metadata": {},
      "source": "maptiler_planet",
      "source-layer": "transportation",
      "filter": [
        "all",
        ["match", ["get", "brunnel"], ["tunnel"], false, true],
        ["==", ["get", "class"], "rail"]
      ],
      "layout": {"visibility": "visible"},
      "paint": {
        "line-color": [
          "interpolate",
          ["linear"],
          ["zoom"],
          8,
          "hsl(0,0%,72%)",
          16,
          "hsl(0,0%,70%)"
        ],
        "line-opacity": ["match", ["get", "service"], "yard", 0.5, 1],
        "line-width": [
          "interpolate",
          ["exponential", 1.4],
          ["zoom"],
          14,
          0.4,
          15,
          0.75,
          20,
          2
        ]
      }
    },
    {
      "id": "Major rail hatching",
      "type": "line",
      "metadata": {},
      "source": "maptiler_planet",
      "source-layer": "transportation",
      "filter": [
        "all",
        ["match", ["get", "brunnel"], ["tunnel"], false, true],
        ["==", ["get", "class"], "rail"]
      ],
      "layout": {"visibility": "visible"},
      "paint": {
        "line-color": "hsl(0,0%,72%)",
        "line-dasharray": [0.2, 9],
        "line-opacity": ["match", ["get", "service"], "yard", 0.5, 1],
        "line-width": [
          "interpolate",
          ["exponential", 1.4],
          ["zoom"],
          14.5,
          0,
          15,
          3,
          20,
          8
        ]
      }
    },
    {
      "id": "Minor rail",
      "type": "line",
      "metadata": {},
      "source": "maptiler_planet",
      "source-layer": "transportation",
      "filter": [
        "match",
        ["get", "subclass"],
        ["light_rail", "tram"],
        true,
        false
      ],
      "layout": {"visibility": "visible"},
      "paint": {
        "line-color": "hsl(0,0%,73%)",
        "line-width": [
          "interpolate",
          ["exponential", 1.4],
          ["zoom"],
          14,
          0.4,
          15,
          0.75,
          20,
          2
        ]
      }
    },
    {
      "id": "Minor rail hatching",
      "type": "line",
      "metadata": {},
      "source": "maptiler_planet",
      "source-layer": "transportation",
      "filter": [
        "match",
        ["get", "subclass"],
        ["light_rail", "tram"],
        true,
        false
      ],
      "layout": {"visibility": "visible"},
      "paint": {
        "line-color": "hsl(0,0%,73%)",
        "line-dasharray": [0.2, 4],
        "line-width": [
          "interpolate",
          ["exponential", 1.4],
          ["zoom"],
          14.5,
          0,
          15,
          2,
          20,
          6
        ]
      }
    },
    {
      "id": "Building",
      "type": "fill",
      "metadata": {},
      "source": "maptiler_planet",
      "source-layer": "building",
      "minzoom": 13,
      "maxzoom": 15,
      "layout": {"visibility": "visible"},
      "paint": {
        "fill-color": "hsl(30,6%,73%)",
        "fill-opacity": 0.3,
        "fill-outline-color": [
          "interpolate",
          ["linear"],
          ["zoom"],
          13,
          "hsla(35,6%,79%,0.3)",
          14,
          "hsl(35,6%,79%)"
        ]
      }
    },
    {
      "id": "Building 3D",
      "type": "fill-extrusion",
      "metadata": {},
      "source": "maptiler_planet",
      "source-layer": "building",
      "minzoom": 15,
      "filter": ["!", ["has", "hide_3d"]],
      "layout": {"visibility": "visible"},
      "paint": {
        "fill-extrusion-base": ["get", "render_min_height"],
        "fill-extrusion-color": "hsl(44,14%,79%)",
        "fill-extrusion-height": ["get", "render_height"],
        "fill-extrusion-opacity": 0.4
      }
    },
    {
      "id": "Aqueduct outline",
      "type": "line",
      "source": "maptiler_planet",
      "source-layer": "waterway",
      "filter": ["==", ["get", "brunnel"], "bridge"],
      "layout": {
        "line-cap": "round",
        "line-join": "round",
        "visibility": "visible"
      },
      "paint": {
        "line-color": "hsl(0,0%,51%)",
        "line-width": [
          "interpolate",
          ["exponential", 1.3],
          ["zoom"],
          14,
          1,
          20,
          6
        ]
      }
    },
    {
      "id": "Aqueduct",
      "type": "line",
      "source": "maptiler_planet",
      "source-layer": "waterway",
      "filter": [
        "all",
        ["==", ["geometry-type"], "LineString"],
        ["==", ["get", "brunnel"], "bridge"]
      ],
      "layout": {
        "line-cap": "round",
        "line-join": "round",
        "visibility": "visible"
      },
      "paint": {
        "line-color": "hsl(204,92%,75%)",
        "line-width": [
          "interpolate",
          ["exponential", 1.3],
          ["zoom"],
          12,
          0.5,
          20,
          5
        ]
      }
    },
    {
      "id": "Cablecar",
      "type": "line",
      "source": "maptiler_planet",
      "source-layer": "transportation",
      "minzoom": 13,
      "filter": ["==", ["get", "class"], "aerialway"],
      "layout": {"line-cap": "round", "visibility": "visible"},
      "paint": {
        "line-blur": 1,
        "line-color": "hsl(0,0%,100%)",
        "line-width": ["interpolate", ["linear"], ["zoom"], 13, 2, 19, 4]
      }
    },
    {
      "id": "Cablecar dash",
      "type": "line",
      "source": "maptiler_planet",
      "source-layer": "transportation",
      "minzoom": 13,
      "filter": ["==", ["get", "class"], "aerialway"],
      "layout": {
        "line-cap": "round",
        "line-join": "bevel",
        "visibility": "visible"
      },
      "paint": {
        "line-color": "hsl(0,0%,64%)",
        "line-dasharray": [2, 2],
        "line-width": ["interpolate", ["linear"], ["zoom"], 13, 1, 19, 2]
      }
    },
    {
      "id": "Other border",
      "type": "line",
      "source": "maptiler_planet",
      "source-layer": "boundary",
      "minzoom": 3,
      "filter": [
        "all",
        ["match", ["get", "admin_level"], [3, 4, 5, 6, 7, 8], true, false],
        ["==", ["get", "maritime"], 0]
      ],
      "layout": {"visibility": "visible"},
      "paint": {
        "line-color": "hsl(0,0%,70%)",
        "line-dasharray": [2, 1],
        "line-width": [
          "interpolate",
          ["linear", 1],
          ["zoom"],
          3,
          0.75,
          4,
          0.8,
          11,
          ["case", ["<=", ["get", "admin_level"], 6], 1.75, 1.5],
          18,
          ["case", ["<=", ["get", "admin_level"], 6], 3, 2]
        ]
      }
    },
    {
      "id": "Disputed border",
      "type": "line",
      "source": "maptiler_planet",
      "source-layer": "boundary",
      "minzoom": 0,
      "filter": [
        "all",
        ["==", ["get", "admin_level"], 2],
        ["==", ["get", "disputed"], 1],
        ["==", ["get", "maritime"], 0]
      ],
      "layout": {
        "line-cap": "round",
        "line-join": "round",
        "visibility": "visible"
      },
      "paint": {
        "line-color": "hsl(0,0%,63%)",
        "line-dasharray": [2, 2],
        "line-width": [
          "interpolate",
          ["linear"],
          ["zoom"],
          1,
          0.5,
          5,
          1.5,
          10,
          2,
          24,
          12
        ]
      }
    },
    {
      "id": "Country border",
      "type": "line",
      "source": "maptiler_planet",
      "source-layer": "boundary",
      "minzoom": 0,
      "filter": [
        "all",
        ["==", ["get", "admin_level"], 2],
        ["==", ["get", "disputed"], 0],
        ["==", ["get", "maritime"], 0]
      ],
      "layout": {
        "line-cap": "round",
        "line-join": "round",
        "visibility": "visible"
      },
      "paint": {
        "line-color": "hsl(0,0%,54%)",
        "line-width": [
          "interpolate",
          ["linear"],
          ["zoom"],
          1,
          0.5,
          5,
          1.5,
          10,
          2,
          24,
          12
        ]
      }
    },
    {
      "id": "River labels",
      "type": "symbol",
      "source": "maptiler_planet",
      "source-layer": "waterway",
      "minzoom": 13,
      "filter": ["==", ["geometry-type"], "LineString"],
      "layout": {
        "symbol-placement": "line",
        "symbol-spacing": 400,
        "text-field": ["coalesce", ["get", "name:en"], ["get", "name"]],
        "text-font": ["Roboto Italic", "Noto Sans Italic"],
        "text-letter-spacing": 0.2,
        "text-max-width": 5,
        "text-rotation-alignment": "map",
        "text-size": [
          "interpolate",
          ["linear"],
          ["zoom"],
          12,
          8,
          16,
          14,
          22,
          20
        ],
        "visibility": "visible"
      },
      "paint": {
        "text-color": "hsl(205,84%,39%)",
        "text-halo-blur": 1,
        "text-halo-color": "hsl(202,76%,82%)",
        "text-halo-width": ["interpolate", ["linear"], ["zoom"], 10, 1, 18, 2]
      }
    },
    {
      "id": "Ocean labels",
      "type": "symbol",
      "metadata": {},
      "source": "maptiler_planet",
      "source-layer": "water_name",
      "minzoom": 0,
      "filter": [
        "all",
        ["==", ["geometry-type"], "Point"],
        ["has", "name"],
        ["!=", ["get", "class"], "lake"]
      ],
      "layout": {
        "symbol-placement": "point",
        "text-field": ["to-string", ["get", "name:en"]],
        "text-font": ["Roboto Italic", "Noto Sans Italic"],
        "text-max-width": 5,
        "text-size": [
          "interpolate",
          ["linear", 1],
          ["zoom"],
          1,
          ["match", ["get", "class"], ["ocean"], 14, 10],
          3,
          ["match", ["get", "class"], ["ocean"], 18, 14],
          9,
          ["match", ["get", "class"], ["ocean"], 22, 18],
          14,
          ["match", ["get", "class"], ["lake"], 14, ["sea"], 20, 26]
        ],
        "visibility": "visible"
      },
      "paint": {
        "text-color": [
          "interpolate",
          ["linear"],
          ["zoom"],
          1,
          "hsl(203,54%,54%)",
          4,
          "hsl(203,72%,39%)"
        ],
        "text-halo-blur": 1,
        "text-halo-color": [
          "interpolate",
          ["linear"],
          ["zoom"],
          1,
          "hsla(196,72%,80%,0.05)",
          3,
          "hsla(200,100%,88%,0.75)"
        ],
        "text-halo-width": 1,
        "text-opacity": [
          "step",
          ["zoom"],
          0,
          1,
          ["match", ["get", "class"], ["ocean"], 1, 0],
          3,
          1
        ]
      }
    },
    {
      "id": "Lake labels",
      "type": "symbol",
      "metadata": {},
      "source": "maptiler_planet",
      "source-layer": "water_name",
      "minzoom": 0,
      "filter": [
        "all",
        ["==", ["geometry-type"], "LineString"],
        ["==", ["get", "class"], "lake"]
      ],
      "layout": {
        "symbol-placement": "line",
        "text-field": ["coalesce", ["get", "name:en"], ["get", "name"]],
        "text-font": ["Roboto Italic", "Noto Sans Italic"],
        "text-letter-spacing": 0.1,
        "text-max-width": 5,
        "text-size": [
          "interpolate",
          ["linear"],
          ["zoom"],
          10,
          13,
          14,
          16,
          22,
          20
        ],
        "visibility": "visible"
      },
      "paint": {
        "text-color": "hsl(205,84%,39%)",
        "text-halo-color": "hsla(0,100%,100%,0.45)",
        "text-halo-width": 1.5
      }
    },
    {
      "id": "Housenumber",
      "type": "symbol",
      "source": "maptiler_planet",
      "source-layer": "housenumber",
      "minzoom": 18,
      "layout": {
        "text-field": ["to-string", ["get", "housenumber"]],
        "text-font": ["Roboto Regular", "Noto Sans Regular"],
        "text-size": 10,
        "visibility": "visible"
      },
      "paint": {
        "text-color": "hsl(26,10%,44%)",
        "text-halo-blur": 1,
        "text-halo-color": "hsl(21,64%,96%)",
        "text-halo-width": 1
      }
    },
    {
      "id": "Gondola",
      "type": "symbol",
      "metadata": {},
      "source": "maptiler_planet",
      "source-layer": "transportation_name",
      "minzoom": 13,
      "filter": [
        "match",
        ["get", "subclass"],
        ["cable_car", "gondola"],
        true,
        false
      ],
      "layout": {
        "symbol-placement": "line",
        "text-anchor": "center",
        "text-field": ["coalesce", ["get", "name:en"], ["get", "name"]],
        "text-font": ["Roboto Italic", "Noto Sans Italic"],
        "text-offset": [0.8, 0.8],
        "text-size": [
          "interpolate",
          ["linear"],
          ["zoom"],
          13,
          11,
          15,
          12,
          18,
          13,
          22,
          14
        ],
        "visibility": "visible"
      },
      "paint": {
        "text-color": "hsl(0,0%,40%)",
        "text-halo-blur": 1,
        "text-halo-color": "hsl(0,0%,100%)",
        "text-halo-width": 1
      }
    },
    {
      "id": "Ferry",
      "type": "symbol",
      "source": "maptiler_planet",
      "source-layer": "transportation_name",
      "minzoom": 12,
      "filter": ["==", ["get", "class"], "ferry"],
      "layout": {
        "symbol-placement": "line",
        "text-anchor": "center",
        "text-field": ["coalesce", ["get", "name:en"], ["get", "name"]],
        "text-font": ["Roboto Italic", "Noto Sans Italic"],
        "text-offset": [0.8, 0.8],
        "text-size": ["interpolate", ["linear"], ["zoom"], 13, 11, 15, 12],
        "visibility": "visible"
      },
      "paint": {
        "text-color": "hsl(205,84%,39%)",
        "text-halo-blur": 0.5,
        "text-halo-color": "hsla(0,0%,100%,0.15)",
        "text-halo-width": 1
      }
    },
    {
      "id": "Oneway",
      "type": "symbol",
      "source": "maptiler_planet",
      "source-layer": "transportation",
      "minzoom": 16,
      "filter": [
        "all",
        ["has", "oneway"],
        [
          "match",
          ["get", "class"],
          [
            "minor",
            "motorway",
            "primary",
            "secondary",
            "service",
            "tertiary",
            "trunk"
          ],
          true,
          false
        ]
      ],
      "layout": {
        "icon-image": "oneway",
        "icon-padding": 2,
        "icon-rotate": ["match", ["get", "oneway"], 1, 0, 0],
        "icon-rotation-alignment": "map",
        "icon-size": ["interpolate", ["linear"], ["zoom"], 16, 0.7, 19, 1],
        "symbol-placement": "line",
        "symbol-spacing": 75,
        "text-font": ["Roboto Regular", "Noto Sans Regular"],
        "visibility": "visible"
      },
      "paint": {"icon-color": "hsl(0,0%,65%)", "icon-opacity": 0.5}
    },
    {
      "id": "Road labels",
      "type": "symbol",
      "metadata": {},
      "source": "maptiler_planet",
      "source-layer": "transportation_name",
      "minzoom": 8,
      "filter": [
        "all",
        ["match", ["get", "subclass"], ["cable_car", "gondola"], false, true],
        ["match", ["get", "class"], ["ferry", "service"], false, true]
      ],
      "layout": {
        "icon-allow-overlap": false,
        "icon-ignore-placement": false,
        "icon-keep-upright": false,
        "symbol-placement": "line",
        "symbol-spacing": ["step", ["zoom"], 250, 22, 500],
        "text-allow-overlap": false,
        "text-anchor": "center",
        "text-field": ["coalesce", ["get", "name:en"], ["get", "name"]],
        "text-font": ["Roboto Regular", "Noto Sans Regular"],
        "text-ignore-placement": false,
        "text-justify": "center",
        "text-max-width": 10,
        "text-offset": [0, 0.15],
        "text-optional": false,
        "text-size": [
          "interpolate",
          ["linear"],
          ["zoom"],
          13,
          10,
          14,
          11,
          18,
          13,
          22,
          15
        ],
        "visibility": "visible"
      },
      "paint": {
        "icon-color": "hsl(0,0%,16%)",
        "text-color": "hsl(0,0%,16%)",
        "text-halo-blur": 0.5,
        "text-halo-color": "hsl(0,0%,100%)",
        "text-halo-width": 1
      }
    },
    {
      "id": "Highway junction",
      "type": "symbol",
      "source": "maptiler_planet",
      "source-layer": "transportation_name",
      "minzoom": 16,
      "filter": [
        "all",
        [">", ["get", "ref_length"], 0],
        ["==", ["geometry-type"], "Point"],
        ["==", ["get", "subclass"], "junction"]
      ],
      "layout": {
        "icon-image": ["concat", "exit_", ["get", "ref_length"]],
        "icon-rotation-alignment": "viewport",
        "icon-size": 1,
        "symbol-avoid-edges": true,
        "symbol-placement": "point",
        "symbol-spacing": 200,
        "symbol-z-order": "auto",
        "text-field": ["to-string", ["get", "ref"]],
        "text-font": ["Roboto Regular", "Noto Sans Regular"],
        "text-offset": [0, 0.1],
        "text-rotation-alignment": "viewport",
        "text-size": 9,
        "visibility": "visible"
      },
      "paint": {
        "text-color": "hsl(0,0%,21%)",
        "text-halo-color": "hsl(0,0%,100%)",
        "text-halo-width": 1
      }
    },
    {
      "id": "Highway shield",
      "type": "symbol",
      "source": "maptiler_planet",
      "source-layer": "transportation_name",
      "minzoom": 8,
      "filter": [
        "all",
        ["<=", ["get", "ref_length"], 6],
        ["==", ["geometry-type"], "LineString"],
        [
          "match",
          ["get", "network"],
          ["us-highway", "us-interstate", "us-state"],
          false,
          true
        ],
        ["match", ["get", "class"], ["path"], false, true]
      ],
      "layout": {
        "icon-image": ["concat", "road_", ["get", "ref_length"]],
        "icon-rotation-alignment": "viewport",
        "icon-size": 1,
        "symbol-avoid-edges": true,
        "symbol-placement": "line",
        "symbol-spacing": [
          "interpolate",
          ["linear"],
          ["zoom"],
          10,
          200,
          18,
          400
        ],
        "text-field": ["to-string", ["get", "ref"]],
        "text-font": [
          "match",
          ["get", "class"],
          "motorway",
          ["literal", ["Roboto Bold", "Noto Sans Bold"]],
          ["literal", ["Roboto Regular"]]
        ],
        "text-offset": [0, 0.05],
        "text-padding": 2,
        "text-rotation-alignment": "viewport",
        "text-size": 10,
        "text-transform": "uppercase",
        "visibility": "visible"
      },
      "paint": {
        "icon-color": "hsl(0,0%,100%)",
        "icon-halo-color": "hsl(0,0%,29%)",
        "icon-halo-width": 1,
        "text-color": "hsl(0,0%,29%)",
        "text-halo-color": "hsl(0,0%,100%)",
        "text-halo-width": 1
      }
    },
    {
      "id": "Highway shield (US)",
      "type": "symbol",
      "source": "maptiler_planet",
      "source-layer": "transportation_name",
      "minzoom": 7,
      "filter": [
        "all",
        ["<=", ["get", "ref_length"], 6],
        ["==", ["geometry-type"], "LineString"],
        ["match", ["get", "network"], ["us-highway", "us-state"], true, false],
        ["match", ["get", "class"], ["path"], false, true]
      ],
      "layout": {
        "icon-image": [
          "concat",
          ["get", "network"],
          "_",
          ["get", "ref_length"]
        ],
        "icon-rotation-alignment": "viewport",
        "icon-size": 1.1,
        "symbol-avoid-edges": true,
        "symbol-placement": ["step", ["zoom"], "point", 7, "line", 8, "line"],
        "symbol-spacing": 200,
        "text-field": ["to-string", ["get", "ref"]],
        "text-font": [
          "match",
          ["get", "class"],
          "motorway",
          ["literal", ["Roboto Bold", "Noto Sans Bold"]],
          ["literal", ["Roboto Regular", "Noto Sans Regular"]]
        ],
        "text-offset": [0, 0.05],
        "text-rotation-alignment": "viewport",
        "text-size": 9,
        "visibility": "visible"
      },
      "paint": {
        "icon-color": "hsl(0,0%,100%)",
        "icon-halo-color": "hsl(0,0%,29%)",
        "icon-halo-width": 1,
        "text-color": "hsl(0,0%,29%)",
        "text-halo-color": "rgba(255, 255, 255, 1)",
        "text-halo-width": 0
      }
    },
    {
      "id": "Highway shield interstate top (US)",
      "type": "symbol",
      "source": "maptiler_planet",
      "source-layer": "transportation_name",
      "minzoom": 7,
      "filter": [
        "all",
        ["<=", ["get", "ref_length"], 6],
        ["==", ["geometry-type"], "LineString"],
        ["==", ["get", "network"], "us-interstate"],
        ["match", ["get", "class"], ["path"], false, true]
      ],
      "layout": {
        "icon-image": [
          "concat",
          ["get", "network"],
          "_",
          ["get", "ref_length"]
        ],
        "icon-rotation-alignment": "viewport",
        "icon-size": 1,
        "symbol-placement": ["step", ["zoom"], "point", 7, "line", 8, "line"],
        "symbol-spacing": 200,
        "text-field": ["to-string", ["get", "ref"]],
        "text-font": [
          "match",
          ["get", "class"],
          "motorway",
          ["literal", ["Roboto Bold", "Noto Sans Bold"]],
          ["literal", ["Roboto Regular", "Noto Sans Regular"]]
        ],
        "text-offset": [0, 0.1],
        "text-rotation-alignment": "viewport",
        "text-size": 9,
        "visibility": "visible"
      },
      "paint": {
        "icon-color": "hsl(21,100%,45%)",
        "icon-halo-color": "rgba(255, 255, 255, 1)",
        "icon-halo-width": 1,
        "icon-translate": [0, -4],
        "icon-translate-anchor": "viewport",
        "text-color": "hsl(21,100%,45%)",
        "text-halo-color": "rgba(255, 255, 255, 1)",
        "text-halo-width": 0
      }
    },
    {
      "id": "Highway shield interstate (US)",
      "type": "symbol",
      "source": "maptiler_planet",
      "source-layer": "transportation_name",
      "minzoom": 7,
      "filter": [
        "all",
        ["<=", ["get", "ref_length"], 6],
        ["==", ["geometry-type"], "LineString"],
        ["==", ["get", "network"], "us-interstate"],
        ["match", ["get", "class"], ["path"], false, true]
      ],
      "layout": {
        "icon-image": [
          "concat",
          ["get", "network"],
          "_",
          ["get", "ref_length"]
        ],
        "icon-rotation-alignment": "viewport",
        "icon-size": 1,
        "symbol-placement": ["step", ["zoom"], "point", 7, "line", 8, "line"],
        "symbol-spacing": 200,
        "text-field": ["to-string", ["get", "ref"]],
        "text-font": [
          "match",
          ["get", "class"],
          "motorway",
          ["literal", ["Roboto Bold", "Noto Sans Bold"]],
          ["literal", ["Roboto Regular", "Noto Sans Regular"]]
        ],
        "text-offset": [0, 0.1],
        "text-rotation-alignment": "viewport",
        "text-size": 9,
        "visibility": "visible"
      },
      "paint": {
        "icon-color": "hsl(212,79%,42%)",
        "icon-halo-color": "rgba(255, 255, 255, 1)",
        "icon-halo-width": 1,
        "text-color": "hsl(0,0%,100%)",
        "text-halo-color": "rgba(255, 255, 255, 1)",
        "text-halo-width": 0,
        "text-translate": [0, -0.5]
      }
    },
    {
      "id": "Public",
      "type": "symbol",
      "metadata": {},
      "source": "maptiler_planet",
      "source-layer": "poi",
      "minzoom": 16,
      "filter": [
        "all",
        ["==", ["geometry-type"], "Point"],
        [
          "match",
          ["get", "class"],
          [
            "atm",
            "bank",
            "bbq",
            "cemetery",
            "courthouse",
            "drinking_water",
            "fire_station",
            "fountain",
            "hairdresser",
            "post",
            "prison",
            "recycling",
            "shower",
            "telephone",
            "toilets",
            "town_hall",
            "townhall"
          ],
          true,
          false
        ]
      ],
      "layout": {
        "icon-image": [
          "match",
          ["get", "class"],
          [
            "atm",
            "bank",
            "bbq",
            "cemetery",
            "courthouse",
            "drinking_water",
            "fire_station",
            "fountain",
            "hairdresser",
            "post",
            "prison",
            "recycling",
            "shower",
            "telephone",
            "toilets",
            "townhall",
            "town_hall"
          ],
          ["get", "class"],
          ["case", ["has", "class"], "", "dot"]
        ],
        "icon-size": 1,
        "symbol-sort-key": ["to-number", ["get", "rank"]],
        "text-anchor": "top",
        "text-field": ["to-string", ["get", "name"]],
        "text-font": ["Roboto Regular", "Noto Sans Regular"],
        "text-max-width": 8,
        "text-offset": [0, 0.8],
        "text-optional": true,
        "text-padding": 2,
        "text-size": [
          "interpolate",
          ["linear"],
          ["zoom"],
          12,
          10,
          16,
          12,
          22,
          14
        ],
        "visibility": "visible"
      },
      "paint": {
        "icon-color": "hsl(51,10%,40%)",
        "icon-halo-blur": [
          "interpolate",
          ["linear"],
          ["zoom"],
          12,
          1,
          14,
          0.8,
          16,
          0
        ],
        "icon-halo-color": "hsl(0,0%,100%)",
        "icon-halo-width": 2,
        "icon-opacity": [
          "step",
          ["zoom"],
          0,
          16,
          [
            "match",
            ["get", "class"],
            ["atm", "bank", "cemetery", "courthouse", "townhall", "town_hall"],
            1,
            0
          ],
          17,
          [
            "match",
            ["get", "class"],
            [
              "atm",
              "bank",
              "cemetery",
              "courthouse",
              "fire_station",
              "townhall",
              "town_hall",
              "post"
            ],
            1,
            0
          ],
          18,
          1
        ],
        "text-color": "hsl(51,10%,40%)",
        "text-halo-blur": [
          "interpolate",
          ["linear"],
          ["zoom"],
          12,
          1,
          14,
          0.5,
          16,
          0
        ],
        "text-halo-color": "hsl(0,0%,100%)",
        "text-halo-width": 2,
        "text-opacity": [
          "step",
          ["zoom"],
          0,
          16,
          [
            "match",
            ["get", "class"],
            ["atm", "bank", "cemetery", "courthouse", "townhall", "town_hall"],
            1,
            0
          ],
          17,
          [
            "match",
            ["get", "class"],
            [
              "atm",
              "bank",
              "cemetery",
              "courthouse",
              "fire_station",
              "townhall",
              "town_hall",
              "post"
            ],
            1,
            0
          ],
          18,
          1
        ]
      }
    },
    {
      "id": "Sport",
      "type": "symbol",
      "metadata": {},
      "source": "maptiler_planet",
      "source-layer": "poi",
      "minzoom": 16,
      "filter": [
        "all",
        ["==", ["geometry-type"], "Point"],
        [
          "match",
          ["get", "class"],
          [
            "american_football",
            "archery",
            "athletics",
            "baseball",
            "basketball",
            "climbing",
            "equestrian",
            "fitness",
            "fitness_centre",
            "golf",
            "motor",
            "multi",
            "pitch",
            "playground",
            "running",
            "sauna",
            "soccer",
            "sport",
            "sports_centre",
            "sports_hall",
            "stadium",
            "swimming",
            "swimming_area",
            "swimming_pool",
            "tennis",
            "volleyball",
            "water_park"
          ],
          true,
          false
        ],
        ["has", "name"]
      ],
      "layout": {
        "icon-image": [
          "coalesce",
          ["image", ["get", "subclass"]],
          ["image", ["get", "class"]],
          ["image", "dot"]
        ],
        "icon-size": 1,
        "symbol-sort-key": ["to-number", ["get", "rank"]],
        "text-anchor": "top",
        "text-field": ["to-string", ["get", "name"]],
        "text-font": ["Roboto Regular", "Noto Sans Regular"],
        "text-max-width": 8,
        "text-offset": [0, 0.8],
        "text-optional": true,
        "text-padding": 2,
        "text-size": [
          "interpolate",
          ["linear"],
          ["zoom"],
          12,
          10,
          16,
          12,
          22,
          14
        ],
        "visibility": "visible"
      },
      "paint": {
        "icon-color": "hsl(129,65%,30%)",
        "icon-halo-blur": [
          "interpolate",
          ["linear"],
          ["zoom"],
          12,
          1,
          14,
          0.8,
          16,
          0
        ],
        "icon-halo-color": "hsl(0,0%,100%)",
        "icon-halo-width": 2,
        "icon-opacity": [
          "step",
          ["zoom"],
          0,
          16,
          [
            "match",
            ["get", "class"],
            ["playground", "pitch", "stadium", "sports_hall", "swimming_pool"],
            1,
            0
          ],
          17,
          1
        ],
        "text-color": "hsl(129,65%,30%)",
        "text-halo-blur": [
          "interpolate",
          ["linear"],
          ["zoom"],
          12,
          1,
          14,
          0.5,
          16,
          0
        ],
        "text-halo-color": "hsl(0,0%,100%)",
        "text-halo-width": 2,
        "text-opacity": [
          "step",
          ["zoom"],
          0,
          16,
          [
            "match",
            ["get", "class"],
            ["playground", "pitch", "stadium", "sports_hall", "swimming_pool"],
            1,
            0
          ],
          17,
          1
        ]
      }
    },
    {
      "id": "Education",
      "type": "symbol",
      "metadata": {},
      "source": "maptiler_planet",
      "source-layer": "poi",
      "minzoom": 15,
      "filter": [
        "all",
        ["==", ["geometry-type"], "Point"],
        [
          "match",
          ["get", "class"],
          [
            "childcare",
            "college",
            "dancing_school",
            "driving_school",
            "kindergarten",
            "school",
            "university"
          ],
          true,
          false
        ],
        ["has", "name"]
      ],
      "layout": {
        "icon-image": [
          "match",
          ["get", "class"],
          [
            "college",
            "childcare",
            "dancing_school",
            "driving_school",
            "kindergarten",
            "school",
            "university"
          ],
          ["get", "class"],
          ["case", ["has", "class"], "", "dot"]
        ],
        "icon-size": 1,
        "symbol-sort-key": ["to-number", ["get", "rank"]],
        "text-anchor": "top",
        "text-field": ["to-string", ["get", "name"]],
        "text-font": ["Roboto Regular", "Noto Sans Regular"],
        "text-max-width": 8,
        "text-offset": [0, 0.8],
        "text-optional": true,
        "text-padding": 2,
        "text-size": [
          "interpolate",
          ["linear"],
          ["zoom"],
          12,
          10,
          16,
          12,
          22,
          14
        ],
        "visibility": "visible"
      },
      "paint": {
        "icon-color": "hsl(175,50%,40%)",
        "icon-halo-blur": [
          "interpolate",
          ["linear"],
          ["zoom"],
          12,
          1,
          14,
          0.8,
          16,
          0
        ],
        "icon-halo-color": "hsl(0,0%,100%)",
        "icon-halo-width": 2,
        "icon-opacity": [
          "step",
          ["zoom"],
          0,
          15,
          ["match", ["get", "subclass"], ["university"], 1, 0],
          16,
          ["match", ["get", "subclass"], ["school", "university"], 1, 0],
          17,
          1
        ],
        "text-color": "hsl(175,50%,40%)",
        "text-halo-blur": [
          "interpolate",
          ["linear"],
          ["zoom"],
          12,
          1,
          14,
          0.5,
          16,
          0
        ],
        "text-halo-color": "hsl(0,0%,100%)",
        "text-halo-width": 2,
        "text-opacity": [
          "step",
          ["zoom"],
          0,
          15,
          ["match", ["get", "subclass"], ["university"], 1, 0],
          16,
          ["match", ["get", "subclass"], ["school", "university"], 1, 0],
          17,
          1
        ]
      }
    },
    {
      "id": "Tourism",
      "type": "symbol",
      "metadata": {},
      "source": "maptiler_planet",
      "source-layer": "poi",
      "minzoom": 14,
      "filter": [
        "all",
        ["==", ["geometry-type"], "Point"],
        [
          "match",
          ["get", "class"],
          [
            "apartment",
            "aquarium",
            "attraction",
            "camp_site",
            "campsite",
            "caravan_site",
            "castle",
            "chalet",
            "guest_house",
            "hostel",
            "hotel",
            "information",
            "lodging",
            "motel",
            "reservoir",
            "ruins",
            "theme_park",
            "zoo"
          ],
          true,
          false
        ],
        ["!=", ["get", "subclass"], "board"],
        ["has", "name"]
      ],
      "layout": {
        "icon-image": [
          "match",
          ["get", "class"],
          [
            "apartment",
            "aquarium",
            "attraction",
            "campsite",
            "camp_site",
            "caravan_site",
            "castle",
            "chalet",
            "guest_house",
            "hotel",
            "hostel",
            "information",
            "lodging",
            "motel",
            "reservoir",
            "ruins",
            "theme_park",
            "zoo"
          ],
          ["get", "class"],
          ["case", ["has", "class"], "", "dot"]
        ],
        "icon-size": 1,
        "symbol-sort-key": ["to-number", ["get", "rank"]],
        "text-anchor": "top",
        "text-field": ["to-string", ["get", "name"]],
        "text-font": ["Roboto Regular", "Noto Sans Regular"],
        "text-max-width": 8,
        "text-offset": [0, 0.8],
        "text-optional": true,
        "text-padding": 2,
        "text-size": [
          "interpolate",
          ["linear"],
          ["zoom"],
          12,
          10,
          16,
          12,
          22,
          14
        ],
        "visibility": "visible"
      },
      "paint": {
        "icon-color": "hsl(283,55%,35%)",
        "icon-halo-blur": [
          "interpolate",
          ["linear"],
          ["zoom"],
          12,
          1,
          14,
          0.8,
          16,
          0
        ],
        "icon-halo-color": "hsl(0,0%,100%)",
        "icon-halo-width": 2,
        "icon-opacity": [
          "step",
          ["zoom"],
          0,
          14,
          ["match", ["get", "subclass"], ["attraction"], 1, 0],
          16,
          [
            "match",
            ["get", "subclass"],
            ["attraction", "castle", "hotel", "zoo"],
            1,
            0
          ],
          17,
          1
        ],
        "text-color": "hsl(283,55%,35%)",
        "text-halo-blur": [
          "interpolate",
          ["linear"],
          ["zoom"],
          12,
          1,
          14,
          0.5,
          16,
          0
        ],
        "text-halo-color": "hsl(0,0%,100%)",
        "text-halo-width": 2,
        "text-opacity": [
          "step",
          ["zoom"],
          0,
          14,
          ["match", ["get", "subclass"], ["attraction"], 1, 0],
          16,
          [
            "match",
            ["get", "subclass"],
            ["attraction", "castle", "hotel", "zoo"],
            1,
            0
          ],
          17,
          1
        ]
      }
    },
    {
      "id": "Culture",
      "type": "symbol",
      "metadata": {},
      "source": "maptiler_planet",
      "source-layer": "poi",
      "minzoom": 14,
      "filter": [
        "all",
        ["==", ["geometry-type"], "Point"],
        [
          "match",
          ["get", "class"],
          [
            "archeological_site",
            "art_gallery",
            "cinema",
            "community_centre",
            "gallery",
            "library",
            "monastery",
            "monument",
            "museum",
            "opera",
            "place_of_worship",
            "planetarium",
            "theatre"
          ],
          true,
          false
        ],
        ["!=", ["get", "subclass"], "artwork"],
        ["has", "name"]
      ],
      "layout": {
        "icon-image": [
          "coalesce",
          ["image", ["get", "subclass"]],
          ["image", ["get", "class"]],
          ["image", "dot"]
        ],
        "icon-size": 1,
        "symbol-sort-key": ["to-number", ["get", "rank"]],
        "text-anchor": "top",
        "text-field": ["to-string", ["get", "name"]],
        "text-font": ["Roboto Regular", "Noto Sans Regular"],
        "text-max-width": 8,
        "text-offset": [0, 0.8],
        "text-optional": true,
        "text-padding": 2,
        "text-size": [
          "interpolate",
          ["linear"],
          ["zoom"],
          12,
          10,
          16,
          12,
          22,
          14
        ],
        "visibility": "visible"
      },
      "paint": {
        "icon-color": "hsl(315,35%,50%)",
        "icon-halo-blur": [
          "interpolate",
          ["linear"],
          ["zoom"],
          12,
          1,
          14,
          0.8,
          16,
          0
        ],
        "icon-halo-color": "hsl(0,0%,100%)",
        "icon-halo-width": 2,
        "icon-opacity": [
          "step",
          ["zoom"],
          0,
          14,
          ["match", ["get", "class"], ["museum"], 1, 0],
          15,
          [
            "match",
            ["get", "class"],
            ["cinema", "art_gallery", "museum", "theatre"],
            1,
            0
          ],
          16,
          [
            "match",
            ["get", "class"],
            [
              "cinema",
              "art_gallery",
              "library",
              "museum",
              "place_of_worship",
              "theatre"
            ],
            1,
            0
          ],
          17,
          1
        ],
        "text-color": "hsl(315,35%,50%)",
        "text-halo-blur": [
          "interpolate",
          ["linear"],
          ["zoom"],
          12,
          1,
          14,
          0.5,
          16,
          0
        ],
        "text-halo-color": "hsl(0,0%,100%)",
        "text-halo-width": 2,
        "text-opacity": [
          "step",
          ["zoom"],
          0,
          14,
          ["match", ["get", "class"], ["museum"], 1, 0],
          15,
          [
            "match",
            ["get", "class"],
            ["cinema", "art_gallery", "museum", "theatre"],
            1,
            0
          ],
          16,
          [
            "match",
            ["get", "class"],
            [
              "cinema",
              "art_gallery",
              "library",
              "museum",
              "place_of_worship",
              "theatre"
            ],
            1,
            0
          ],
          17,
          1
        ]
      }
    },
    {
      "id": "Shopping",
      "type": "symbol",
      "metadata": {},
      "source": "maptiler_planet",
      "source-layer": "poi",
      "minzoom": 14,
      "filter": [
        "all",
        ["==", ["geometry-type"], "Point"],
        [
          "all",
          [
            "match",
            ["get", "class"],
            [
              "alcohol_shop",
              "bakery",
              "book",
              "books",
              "butcher",
              "chemist",
              "clothing_store",
              "convenience",
              "gift",
              "grocery",
              "laundry",
              "mall",
              "music",
              "shop",
              "supermarket"
            ],
            true,
            false
          ],
          ["has", "name"]
        ]
      ],
      "layout": {
        "icon-image": [
          "coalesce",
          ["image", ["get", "subclass"]],
          ["image", ["get", "class"]],
          ["image", "dot"]
        ],
        "icon-size": 1,
        "symbol-sort-key": ["to-number", ["get", "rank"]],
        "text-anchor": "top",
        "text-field": ["to-string", ["get", "name"]],
        "text-font": ["Roboto Regular", "Noto Sans Regular"],
        "text-max-width": 8,
        "text-offset": [0, 0.8],
        "text-optional": true,
        "text-padding": 2,
        "text-size": [
          "interpolate",
          ["linear"],
          ["zoom"],
          12,
          10,
          16,
          12,
          22,
          14
        ],
        "visibility": "visible"
      },
      "paint": {
        "icon-color": "hsl(18,17%,30%)",
        "icon-halo-blur": [
          "interpolate",
          ["linear"],
          ["zoom"],
          12,
          1,
          14,
          0.8,
          16,
          0
        ],
        "icon-halo-color": "hsl(0,0%,100%)",
        "icon-halo-width": 2,
        "icon-opacity": [
          "step",
          ["zoom"],
          0,
          14,
          ["match", ["get", "subclass"], ["mall"], 1, 0],
          15,
          ["match", ["get", "subclass"], ["mall", "supermarket"], 1, 0],
          16,
          [
            "match",
            ["get", "subclass"],
            ["bakery", "chemist", "mall", "supermarket"],
            1,
            0
          ],
          17,
          1
        ],
        "text-color": "hsl(18,17%,30%)",
        "text-halo-blur": [
          "interpolate",
          ["linear"],
          ["zoom"],
          12,
          1,
          14,
          0.5,
          16,
          0
        ],
        "text-halo-color": "hsl(0,0%,100%)",
        "text-halo-width": 2,
        "text-opacity": [
          "step",
          ["zoom"],
          0,
          14,
          ["match", ["get", "subclass"], ["mall"], 1, 0],
          15,
          ["match", ["get", "subclass"], ["mall", "supermarket"], 1, 0],
          16,
          [
            "match",
            ["get", "subclass"],
            ["bakery", "chemist", "mall", "supermarket"],
            1,
            0
          ],
          17,
          1
        ]
      }
    },
    {
      "id": "Food",
      "type": "symbol",
      "metadata": {},
      "source": "maptiler_planet",
      "source-layer": "poi",
      "minzoom": 14,
      "maxzoom": 22,
      "filter": [
        "all",
        ["==", ["geometry-type"], "Point"],
        [
          "match",
          ["get", "class"],
          [
            "bar",
            "beer",
            "biergarten",
            "cafe",
            "fast_food",
            "food_court",
            "ice_cream",
            "pub",
            "restaurant"
          ],
          true,
          false
        ],
        ["has", "name"]
      ],
      "layout": {
        "icon-image": [
          "match",
          ["get", "class"],
          ["bar", "beer", "cafe", "fast_food", "ice_cream", "restaurant"],
          ["get", "class"],
          ["biergarten", "pub"],
          "beer",
          "",
          ["get", "class"],
          ["food_court"],
          "restaurant",
          "dot"
        ],
        "icon-size": 1,
        "symbol-sort-key": ["to-number", ["get", "rank"]],
        "text-anchor": "top",
        "text-field": ["to-string", ["get", "name"]],
        "text-font": ["Roboto Regular", "Noto Sans Regular"],
        "text-max-width": 8,
        "text-offset": [0, 0.8],
        "text-optional": true,
        "text-padding": 2,
        "text-size": [
          "interpolate",
          ["linear"],
          ["zoom"],
          12,
          10,
          16,
          12,
          22,
          14
        ],
        "visibility": "visible"
      },
      "paint": {
        "icon-color": "hsl(18,24%,44%)",
        "icon-halo-blur": [
          "interpolate",
          ["linear"],
          ["zoom"],
          12,
          1,
          14,
          0.8,
          16,
          0
        ],
        "icon-halo-color": "hsl(0,0%,100%)",
        "icon-halo-width": 2,
        "icon-opacity": [
          "step",
          ["zoom"],
          0,
          14,
          ["case", ["<=", ["get", "rank"], 20], 1, 0],
          15,
          ["case", ["<=", ["get", "rank"], 99], 1, 0],
          16,
          ["case", ["<=", ["get", "rank"], 499], 1, 0],
          17,
          1
        ],
        "text-color": "hsl(18,24%,44%)",
        "text-halo-blur": [
          "interpolate",
          ["linear"],
          ["zoom"],
          12,
          1,
          14,
          0.5,
          16,
          0
        ],
        "text-halo-color": "hsl(0,0%,100%)",
        "text-halo-width": 2,
        "text-opacity": [
          "step",
          ["zoom"],
          0,
          14,
          ["case", ["<=", ["get", "rank"], 20], 1, 0],
          15,
          ["case", ["<=", ["get", "rank"], 99], 1, 0],
          16,
          ["case", ["<=", ["get", "rank"], 499], 1, 0],
          17,
          1
        ]
      }
    },
    {
      "id": "Transport",
      "type": "symbol",
      "metadata": {},
      "source": "maptiler_planet",
      "source-layer": "poi",
      "minzoom": 14,
      "filter": [
        "all",
        ["==", ["geometry-type"], "Point"],
        [
          "match",
          ["get", "class"],
          [
            "bicycle",
            "bicycle_parking",
            "bicycle_rental",
            "car",
            "car_rental",
            "car_repair",
            "charging_station",
            "ferry_terminal",
            "fuel",
            "harbor",
            "heliport",
            "highway_rest_area",
            "motorcycle_parking",
            "parking",
            "parking_garage",
            "parking_paid",
            "scooter",
            "terminal",
            "toll"
          ],
          true,
          false
        ]
      ],
      "layout": {
        "icon-image": [
          "match",
          ["get", "class"],
          [
            "aerialway",
            "bicycle",
            "bicycle_parking",
            "car",
            "car_rental",
            "car_repair",
            "charging_station",
            "cycle_barrier",
            "ferry_terminal",
            "fuel",
            "harbor",
            "motorcycle_parking",
            "parking",
            "parking_garage",
            "parking_paid"
          ],
          ["get", "class"],
          ["case", ["has", "class"], "dot", ""]
        ],
        "icon-size": 1,
        "symbol-sort-key": ["to-number", ["get", "rank"]],
        "text-anchor": "top",
        "text-field": ["to-string", ["get", "name"]],
        "text-font": ["Roboto Regular", "Noto Sans Regular"],
        "text-max-width": 8,
        "text-offset": [0, 0.8],
        "text-optional": true,
        "text-padding": 2,
        "text-size": [
          "interpolate",
          ["linear"],
          ["zoom"],
          12,
          10,
          16,
          12,
          22,
          14
        ],
        "visibility": "visible"
      },
      "paint": {
        "icon-color": "hsl(215,81%,35%)",
        "icon-halo-blur": [
          "interpolate",
          ["linear"],
          ["zoom"],
          12,
          1,
          14,
          0.8,
          16,
          0
        ],
        "icon-halo-color": "hsl(0,0%,100%)",
        "icon-halo-width": 2,
        "icon-opacity": [
          "step",
          ["zoom"],
          0,
          14,
          [
            "match",
            ["get", "class"],
            ["ferry_terminal", "fuel", "terminal"],
            1,
            0
          ],
          16,
          [
            "match",
            ["get", "class"],
            [
              "car",
              "car_rental",
              "car_repair",
              "charging_station",
              "ferry_terminal",
              "fuel",
              "harbor",
              "heliport",
              "highway_rest_area",
              "terminal",
              "toll"
            ],
            1,
            0
          ],
          17,
          [
            "match",
            ["get", "class"],
            [
              "car",
              "car_rental",
              "car_repair",
              "charging_station",
              "ferry_terminal",
              "fuel",
              "harbor",
              "heliport",
              "highway_rest_area",
              "parking",
              "parking_garage",
              "parking_paid",
              "terminal",
              "toll"
            ],
            1,
            0
          ],
          18,
          1
        ],
        "text-color": "hsl(215,81%,35%)",
        "text-halo-blur": [
          "interpolate",
          ["linear"],
          ["zoom"],
          12,
          1,
          14,
          0.5,
          16,
          0
        ],
        "text-halo-color": "hsl(0,0%,100%)",
        "text-halo-width": 2,
        "text-opacity": [
          "step",
          ["zoom"],
          0,
          14,
          [
            "match",
            ["get", "class"],
            ["ferry_terminal", "fuel", "terminal"],
            1,
            0
          ],
          16,
          [
            "match",
            ["get", "class"],
            [
              "car",
              "car_rental",
              "car_repair",
              "charging_station",
              "ferry_terminal",
              "fuel",
              "harbor",
              "heliport",
              "highway_rest_area",
              "terminal",
              "toll"
            ],
            1,
            0
          ],
          17,
          [
            "match",
            ["get", "class"],
            [
              "car",
              "car_rental",
              "car_repair",
              "charging_station",
              "ferry_terminal",
              "fuel",
              "harbor",
              "heliport",
              "highway_rest_area",
              "parking",
              "parking_garage",
              "parking_paid",
              "terminal",
              "toll"
            ],
            1,
            0
          ],
          18,
          1
        ]
      }
    },
    {
      "id": "Park",
      "type": "symbol",
      "metadata": {},
      "source": "maptiler_planet",
      "source-layer": "poi",
      "minzoom": 14,
      "filter": ["all", ["==", ["get", "class"], "park"], ["has", "name"]],
      "layout": {
        "icon-anchor": "center",
        "icon-image": "park",
        "symbol-sort-key": ["to-number", ["get", "rank"]],
        "text-anchor": "top",
        "text-field": ["to-string", ["get", "name"]],
        "text-font": ["Roboto Regular", "Noto Sans Regular"],
        "text-max-width": 8,
        "text-offset": [0, 0.8],
        "text-optional": true,
        "text-padding": 2,
        "text-size": [
          "interpolate",
          ["linear"],
          ["zoom"],
          12,
          10,
          16,
          12,
          22,
          14
        ],
        "visibility": "visible"
      },
      "paint": {
        "icon-color": "hsl(82,83%,25%)",
        "icon-halo-blur": 0,
        "icon-halo-color": "hsl(0,0%,100%)",
        "icon-halo-width": 2,
        "icon-opacity": [
          "step",
          ["zoom"],
          0,
          14,
          ["case", ["<=", ["get", "rank"], 10], 1, 0],
          15,
          ["case", ["<=", ["get", "rank"], 99], 1, 0],
          16,
          1
        ],
        "text-color": "hsl(82,83%,25%)",
        "text-halo-blur": 0,
        "text-halo-color": "hsl(0,0%,100%)",
        "text-halo-width": 2,
        "text-opacity": [
          "step",
          ["zoom"],
          0,
          14,
          ["case", ["<=", ["get", "rank"], 10], 1, 0],
          15,
          ["case", ["<=", ["get", "rank"], 99], 1, 0],
          16,
          1
        ]
      }
    },
    {
      "id": "Healthcare",
      "type": "symbol",
      "metadata": {},
      "source": "maptiler_planet",
      "source-layer": "poi",
      "minzoom": 14,
      "filter": [
        "all",
        ["==", ["geometry-type"], "Point"],
        [
          "match",
          ["get", "class"],
          [
            "clinic",
            "dentist",
            "doctors",
            "first_aid",
            "hospital",
            "pharmacy",
            "veterinary"
          ],
          true,
          false
        ],
        ["has", "name"]
      ],
      "layout": {
        "icon-image": [
          "match",
          ["get", "class"],
          [
            "clinic",
            "dentist",
            "doctors",
            "doctor",
            "first_aid",
            "hospital",
            "pharmacy",
            "veterinary"
          ],
          ["get", "class"],
          ["case", ["has", "class"], "", "dot"]
        ],
        "icon-size": 1,
        "symbol-sort-key": ["to-number", ["get", "rank"]],
        "text-anchor": "top",
        "text-field": ["to-string", ["get", "name"]],
        "text-font": ["Roboto Regular", "Noto Sans Regular"],
        "text-max-width": 8,
        "text-offset": [0, 0.8],
        "text-optional": true,
        "text-padding": 2,
        "text-size": [
          "interpolate",
          ["linear"],
          ["zoom"],
          12,
          10,
          16,
          12,
          22,
          14
        ],
        "visibility": "visible"
      },
      "paint": {
        "icon-color": "hsl(6,96%,35%)",
        "icon-halo-blur": [
          "interpolate",
          ["linear"],
          ["zoom"],
          12,
          1,
          14,
          0.8,
          16,
          0
        ],
        "icon-halo-color": "hsl(0,0%,100%)",
        "icon-halo-width": 2,
        "icon-opacity": [
          "step",
          ["zoom"],
          0,
          14,
          ["match", ["get", "subclass"], ["hospital"], 1, 0],
          16,
          ["match", ["get", "class"], ["clinic", "hospital"], 1, 0],
          17,
          1
        ],
        "text-color": "hsl(6,96%,35%)",
        "text-halo-blur": [
          "interpolate",
          ["linear"],
          ["zoom"],
          12,
          1,
          14,
          0.5,
          16,
          0
        ],
        "text-halo-color": "hsl(0,0%,100%)",
        "text-halo-width": 2,
        "text-opacity": [
          "step",
          ["zoom"],
          0,
          14,
          ["match", ["get", "subclass"], ["hospital"], 1, 0],
          16,
          ["match", ["get", "class"], ["clinic", "hospital"], 1, 0],
          17,
          1
        ]
      }
    },
    {
      "id": "Place labels",
      "type": "symbol",
      "metadata": {},
      "source": "maptiler_planet",
      "source-layer": "place",
      "minzoom": 4,
      "filter": [
        "match",
        ["get", "class"],
        ["city", "continent", "country", "province", "region", "state", "town"],
        false,
        true
      ],
      "layout": {
        "symbol-sort-key": ["to-number", ["get", "rank"]],
        "text-anchor": "center",
        "text-field": ["to-string", ["get", "name"]],
        "text-font": ["Roboto Regular", "Noto Sans Regular"],
        "text-letter-spacing": [
          "match",
          ["get", "class"],
          ["suburb", "neighborhood", "neighbourhood", "quarter", "island"],
          0.2,
          0
        ],
        "text-max-width": ["match", ["get", "class"], ["island"], 6, 8],
        "text-offset": [0, 0],
        "text-padding": 2,
        "text-size": [
          "interpolate",
          ["linear", 1],
          ["zoom"],
          3,
          11,
          8,
          13,
          11,
          [
            "match",
            ["get", "class"],
            "village",
            12,
            [
              "suburb",
              "neighbourhood",
              "quarter",
              "hamlet",
              "isolated_dwelling"
            ],
            9,
            "island",
            8,
            12
          ],
          16,
          [
            "match",
            ["get", "class"],
            "village",
            18,
            [
              "suburb",
              "neighbourhood",
              "quarter",
              "hamlet",
              "isolated_dwelling"
            ],
            15,
            "island",
            11,
            16
          ]
        ],
        "text-transform": [
          "match",
          ["get", "class"],
          ["suburb", "neighborhood", "neighbourhood", "quarter", "island"],
          "uppercase",
          "none"
        ],
        "visibility": "visible"
      },
      "paint": {
        "text-color": "hsl(0,0%,25%)",
        "text-halo-color": "hsl(0,0%,100%)",
        "text-halo-width": 1.2,
        "text-opacity": [
          "step",
          ["zoom"],
          1,
          8,
          ["match", ["get", "class"], ["island"], 0, 1],
          9,
          ["match", ["get", "class"], ["island"], 1, 1]
        ]
      }
    },
    {
      "id": "Station",
      "type": "symbol",
      "metadata": {},
      "source": "maptiler_planet",
      "source-layer": "poi",
      "minzoom": 12,
      "filter": [
        "all",
        ["match", ["get", "class"], ["bus", "railway"], true, false],
        ["has", "name"]
      ],
      "layout": {
        "icon-image": [
          "match",
          ["get", "subclass"],
          ["bus_stop", "subway"],
          ["get", "subclass"],
          "bus_station",
          "bus_stop",
          "station",
          "railway",
          "tram_stop",
          "tramway",
          ["case", ["has", "subclass"], "dot", ""]
        ],
        "icon-size": 1,
        "symbol-sort-key": ["to-number", ["get", "rank"]],
        "text-anchor": "top",
        "text-field": ["to-string", ["get", "name"]],
        "text-font": ["Roboto Medium", "Noto Sans Regular"],
        "text-line-height": 0.9,
        "text-max-width": 9,
        "text-offset": [0, 0.9],
        "text-optional": true,
        "text-padding": 2,
        "text-size": [
          "interpolate",
          ["linear"],
          ["zoom"],
          13,
          11,
          16,
          12,
          22,
          16
        ],
        "visibility": "visible"
      },
      "paint": {
        "icon-color": "hsl(215,83%,53%)",
        "icon-halo-blur": [
          "interpolate",
          ["linear"],
          ["zoom"],
          12,
          1,
          14,
          0.8,
          16,
          0
        ],
        "icon-halo-color": "hsl(0,0%,100%)",
        "icon-halo-width": 2,
        "icon-opacity": [
          "step",
          ["zoom"],
          0,
          12,
          ["match", ["get", "subclass"], ["station"], 1, 0],
          14,
          [
            "match",
            ["get", "subclass"],
            ["station", "subway", "tram_stop"],
            1,
            0
          ],
          16,
          [
            "match",
            ["get", "subclass"],
            ["bus_stop", "station", "subway", "tram_stop"],
            1,
            0
          ],
          17,
          1
        ],
        "text-color": "hsl(215,83%,53%)",
        "text-halo-blur": [
          "interpolate",
          ["linear"],
          ["zoom"],
          12,
          1,
          14,
          0.5,
          16,
          0
        ],
        "text-halo-color": "hsl(0,0%,100%)",
        "text-halo-width": 2,
        "text-opacity": [
          "step",
          ["zoom"],
          0,
          12,
          ["match", ["get", "subclass"], ["station"], 1, 0],
          14,
          [
            "match",
            ["get", "subclass"],
            ["station", "subway", "tram_stop"],
            1,
            0
          ],
          16,
          [
            "match",
            ["get", "subclass"],
            ["bus_stop", "station", "subway", "tram_stop"],
            1,
            0
          ],
          17,
          1
        ]
      }
    },
    {
      "id": "Airport gate",
      "type": "symbol",
      "source": "maptiler_planet",
      "source-layer": "aeroway",
      "minzoom": 15,
      "filter": ["==", ["get", "class"], "gate"],
      "layout": {
        "text-field": ["to-string", ["get", "ref"]],
        "text-font": ["Roboto Medium", "Noto Sans Regular"],
        "text-size": ["interpolate", ["linear"], ["zoom"], 15, 10, 22, 18],
        "visibility": "visible"
      },
      "paint": {
        "text-color": "hsl(0,0%,40%)",
        "text-halo-blur": 0.5,
        "text-halo-color": "hsl(0,0%,100%)",
        "text-halo-width": 1
      }
    },
    {
      "id": "Airport",
      "type": "symbol",
      "source": "maptiler_planet",
      "source-layer": "aerodrome_label",
      "minzoom": 8,
      "filter": [
        "all",
        ["has", "iata"],
        ["match", ["get", "class"], ["public"], false, true]
      ],
      "layout": {
        "icon-image": [
          "match",
          ["get", "class"],
          "international",
          "airport",
          "airfield"
        ],
        "icon-size": [
          "interpolate",
          ["linear"],
          ["zoom"],
          8,
          0.6,
          10,
          ["match", ["get", "class"], "international", 0.8, 0.6],
          16,
          ["match", ["get", "class"], "international", 1, 0.8]
        ],
        "text-anchor": "top",
        "text-field": [
          "step",
          ["zoom"],
          " ",
          9,
          ["to-string", ["get", "iata"]],
          12,
          ["to-string", ["get", "name:en"]]
        ],
        "text-font": ["Roboto Medium", "Noto Sans Regular"],
        "text-line-height": 1.2,
        "text-max-width": 9,
        "text-offset": [0, 0.8],
        "text-optional": true,
        "text-padding": 2,
        "text-size": [
          "interpolate",
          ["linear"],
          ["zoom"],
          9,
          9,
          10,
          ["match", ["get", "class"], "international", 10, 7],
          14,
          ["match", ["get", "class"], "international", 13, 11]
        ],
        "visibility": "visible"
      },
      "paint": {
        "icon-color": "hsl(215,83%,53%)",
        "icon-halo-blur": [
          "interpolate",
          ["linear"],
          ["zoom"],
          8,
          1,
          10,
          0.5,
          12,
          0
        ],
        "icon-halo-color": "hsl(0,0%,100%)",
        "icon-halo-width": ["interpolate", ["linear"], ["zoom"], 8, 1, 12, 2],
        "icon-opacity": 1,
        "text-color": "hsl(215,83%,53%)",
        "text-halo-blur": [
          "interpolate",
          ["linear"],
          ["zoom"],
          8,
          1,
          10,
          0.5,
          12,
          0
        ],
        "text-halo-color": "hsl(0,0%,100%)",
        "text-halo-width": ["interpolate", ["linear"], ["zoom"], 8, 1, 12, 2]
      }
    },
    {
      "id": "State labels",
      "type": "symbol",
      "metadata": {},
      "source": "maptiler_planet",
      "source-layer": "place",
      "minzoom": 3,
      "maxzoom": 9,
      "filter": [
        "all",
        ["match", ["get", "class"], ["province", "state"], true, false],
        ["<=", ["get", "rank"], 6]
      ],
      "layout": {
        "symbol-sort-key": ["to-number", ["get", "rank"]],
        "text-field": ["coalesce", ["get", "name:en"], ["get", "name"]],
        "text-font": ["Roboto Medium", "Noto Sans Regular"],
        "text-letter-spacing": 0.1,
        "text-max-width": 8,
        "text-padding": 2,
        "text-size": ["interpolate", ["linear"], ["zoom"], 3, 9, 5, 10, 6, 11],
        "text-transform": "uppercase",
        "visibility": "visible"
      },
      "paint": {
        "text-color": "hsl(48,4%,44%)",
        "text-halo-color": "hsla(0,0%,100%,0.75)",
        "text-halo-width": 0.8,
        "text-opacity": [
          "step",
          ["zoom"],
          0,
          3,
          ["case", ["<=", ["get", "rank"], 3], 1, 0],
          8,
          ["case", ["==", ["get", "rank"], 0], 0, 1]
        ]
      }
    },
    {
      "id": "Town labels",
      "type": "symbol",
      "metadata": {},
      "source": "maptiler_planet",
      "source-layer": "place",
      "minzoom": 4,
      "maxzoom": 16,
      "filter": ["==", ["get", "class"], "town"],
      "layout": {
        "icon-allow-overlap": true,
        "icon-image": ["step", ["zoom"], "circle", 12, " "],
        "icon-optional": false,
        "icon-size": [
          "interpolate",
          ["exponential", 1],
          ["zoom"],
          6,
          0.3,
          14,
          0.4
        ],
        "symbol-sort-key": ["to-number", ["get", "rank"]],
        "text-anchor": "bottom",
        "text-field": ["coalesce", ["get", "name:en"], ["get", "name"]],
        "text-font": ["Roboto Regular", "Noto Sans Regular"],
        "text-max-width": 8,
        "text-offset": [0, -0.15],
        "text-size": [
          "interpolate",
          ["linear", 1],
          ["zoom"],
          6,
          ["case", ["<=", ["get", "rank"], 12], 11, 10],
          9,
          ["case", ["<=", ["get", "rank"], 15], 13, 12],
          16,
          ["case", ["<=", ["get", "rank"], 15], 22, 20]
        ],
        "visibility": "visible"
      },
      "paint": {
        "icon-color": "hsl(0,20%,99%)",
        "icon-halo-color": "hsl(0,0%,29%)",
        "icon-halo-width": 1,
        "text-color": [
          "interpolate",
          ["linear"],
          ["zoom"],
          6,
          "hsl(0,0%,20%)",
          12,
          "hsl(0,0%,0%)"
        ],
        "text-halo-blur": 0.5,
        "text-halo-color": "hsl(0,0%,100%)",
        "text-halo-width": 1
      }
    },
    {
      "id": "City labels",
      "type": "symbol",
      "metadata": {},
      "source": "maptiler_planet",
      "source-layer": "place",
      "minzoom": 4,
      "maxzoom": 16,
      "filter": [
        "all",
        ["==", ["get", "class"], "city"],
        ["!=", ["get", "capital"], 2]
      ],
      "layout": {
        "icon-allow-overlap": true,
        "icon-image": ["step", ["zoom"], "circle", 13, ""],
        "icon-optional": false,
        "icon-size": 0.4,
        "symbol-sort-key": ["to-number", ["get", "rank"]],
        "text-anchor": "bottom",
        "text-field": ["to-string", ["get", "name:en"]],
        "text-font": ["Roboto Medium", "Noto Sans Regular"],
        "text-max-width": 8,
        "text-offset": [0, -0.15],
        "text-size": [
          "interpolate",
          ["linear", 1],
          ["zoom"],
          4,
          ["case", ["<=", ["get", "rank"], 2], 14, 12],
          8,
          ["case", ["<=", ["get", "rank"], 4], 18, 14],
          12,
          ["case", ["<=", ["get", "rank"], 4], 24, 18],
          16,
          ["case", ["<=", ["get", "rank"], 4], 32, 26]
        ],
        "visibility": "visible"
      },
      "paint": {
        "icon-color": "hsl(0,0%,100%)",
        "icon-halo-color": "hsl(0,0%,29%)",
        "icon-halo-width": 1,
        "icon-opacity": 1,
        "text-color": "hsl(0,0%,20%)",
        "text-halo-blur": 0.5,
        "text-halo-color": "hsl(0,0%,100%)",
        "text-halo-width": 0.8
      }
    },
    {
      "id": "Capital city labels",
      "type": "symbol",
      "metadata": {},
      "source": "maptiler_planet",
      "source-layer": "place",
      "minzoom": 4,
      "maxzoom": 16,
      "filter": [
        "all",
        ["==", ["get", "class"], "city"],
        ["==", ["get", "capital"], 2]
      ],
      "layout": {
        "icon-allow-overlap": true,
        "icon-image": ["step", ["zoom"], "circle", 13, ""],
        "icon-optional": false,
        "icon-size": [
          "interpolate",
          ["linear", 1],
          ["zoom"],
          4,
          0.45,
          10,
          0.5,
          11,
          0.6
        ],
        "symbol-sort-key": ["to-number", ["get", "rank"]],
        "text-anchor": "bottom",
        "text-field": ["to-string", ["get", "name:en"]],
        "text-font": ["Roboto Medium", "Noto Sans Regular"],
        "text-max-width": 8,
        "text-offset": [0, -0.15],
        "text-size": [
          "interpolate",
          ["linear", 1],
          ["zoom"],
          4,
          14,
          8,
          18,
          12,
          24,
          16,
          32
        ],
        "visibility": "visible"
      },
      "paint": {
        "icon-color": "hsl(0,0%,100%)",
        "icon-halo-color": "hsl(0,0%,29%)",
        "icon-halo-width": 1,
        "icon-opacity": 1,
        "text-color": "hsl(0,0%,20%)",
        "text-halo-blur": 0.5,
        "text-halo-color": "hsl(0,0%,100%)",
        "text-halo-width": 0.8
      }
    },
    {
      "id": "Country labels",
      "type": "symbol",
      "metadata": {},
      "source": "maptiler_planet",
      "source-layer": "place",
      "minzoom": 1,
      "maxzoom": 12,
      "filter": [
        "all",
        ["==", ["get", "class"], "country"],
        ["has", "iso_a2"],
        ["!=", ["get", "iso_a2"], "VA"]
      ],
      "layout": {
        "symbol-sort-key": ["to-number", ["get", "rank"]],
        "text-allow-overlap": false,
        "text-field": ["to-string", ["get", "name:en"]],
        "text-font": ["Roboto Medium", "Noto Sans Regular"],
        "text-letter-spacing": 0.07,
        "text-max-width": ["interpolate", ["linear"], ["zoom"], 1, 5, 5, 8],
        "text-padding": 1,
        "text-size": [
          "interpolate",
          ["linear", 1],
          ["zoom"],
          0,
          8,
          1,
          10,
          4,
          ["case", [">", ["get", "rank"], 2], 15, 17],
          8,
          ["case", [">", ["get", "rank"], 2], 19, 23]
        ],
        "text-transform": "none",
        "visibility": "visible"
      },
      "paint": {
        "text-color": "hsl(0,0%,20%)",
        "text-halo-blur": 0.8,
        "text-halo-color": "hsl(0,0%,100%)",
        "text-halo-width": 1,
        "text-opacity": [
          "interpolate",
          ["linear", 1],
          ["zoom"],
          4,
          ["case", [">", ["get", "rank"], 4], 0, 1],
          5.9,
          ["case", [">", ["get", "rank"], 4], 0, 1],
          6,
          ["case", [">", ["get", "rank"], 4], 1, 1]
        ]
      }
    },
    {
      "id": "Continent labels",
      "type": "symbol",
      "metadata": {},
      "source": "maptiler_planet",
      "source-layer": "place",
      "maxzoom": 1,
      "filter": ["==", ["get", "class"], "continent"],
      "layout": {
        "text-field": ["to-string", ["get", "name:en"]],
        "text-font": ["Roboto Medium", "Noto Sans Regular"],
        "text-justify": "center",
        "text-size": ["interpolate", ["linear"], ["zoom"], 0, 12, 2, 13],
        "text-transform": "uppercase",
        "visibility": "visible"
      },
      "paint": {
        "text-color": "hsl(0,0%,19%)",
        "text-halo-blur": 1,
        "text-halo-color": "hsl(0,0%,100%)",
        "text-halo-width": 1
      }
    }
  ],
  "id": "streets-v2"
}
''';
