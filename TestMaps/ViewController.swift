import UIKit
import MapboxMaps

final class ViewController: UIViewController {
    private lazy var mapView: MapView = MapView(frame: view.bounds)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        mapView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.addSubview(mapView)
        
        mapView.mapboxMap.loadStyle(.standard) { [weak self] error in
            guard error == nil else { return }
            self?.addMarkersAndFitBounds()
        }
    }
    
    private func addMarkersAndFitBounds() {
        // Define your pin coordinates
       
        let places: [(coord: CLLocationCoordinate2D, name: String)] = [
                (CLLocationCoordinate2D(latitude: 51.45786, longitude: -0.97888), "Reading - My BackGarden"),
                (CLLocationCoordinate2D(latitude: 50.41283, longitude: -5.10309), "Cornwall - Relaxing Holiday"),
                (CLLocationCoordinate2D(latitude: 50.62135, longitude: -2.27683), "Durdle Door - Prehistoric Coastline"),
                (CLLocationCoordinate2D(latitude: 57.57415, longitude: -4.09474), "Chanory point - Best Dolphin spotting")
            ]
       
        let coordinates = places.map { $0.coord } // extracting co-ordinates from places
        
        // Add marker image
        try? mapView.mapboxMap.addImage(UIImage(named: "dest-pin")!, id: "marker-icon")
        
   
        // Create features for all markers
       
        let features = places.map { coord, name -> Feature in
                      var feature = Feature(geometry: Point(coord))
                      feature.properties = [
                          "title": .string(name)          // <-- this will be used for the label
                      ]
                      return feature
                  }
              
              
        
        
        // Add source with all markers
        var source = GeoJSONSource(id: "markers-source")
        source.data = .featureCollection(FeatureCollection(features: features))
        try? mapView.mapboxMap.addSource(source)
        
        
        
        // Fit camera to show all markers
        let cameraOptions = try? mapView.mapboxMap.camera(
            for: coordinates,
            camera: CameraOptions(),
            coordinatesPadding: UIEdgeInsets(top: 200, left: 50, bottom: 50, right: 50),
            maxZoom: nil,
            offset: nil
        )
        
        if let cameraOptions = cameraOptions {
            mapView.camera.ease(to: cameraOptions, duration: 1.0)
        }
        
     
        // Add symbol layer
        var layer = SymbolLayer(id: "markers-layer", source: "markers-source")
        layer.iconImage = .constant(.name("marker-icon"))
        layer.iconAnchor = .constant(.bottom)
        layer.iconOffset = .constant([0, 12])
        try? mapView.mapboxMap.addLayer(layer)
        
        var iconLayer = SymbolLayer(id: "markers-icon-layer", source: "markers-source")
                    iconLayer.iconImage = .constant(.name("marker-icon"))
                    iconLayer.iconAnchor = .constant(.bottom)
                    iconLayer.iconOffset = .constant([0, 12])          // push icon up a bit
                    try? mapView.mapboxMap.addLayer(iconLayer)
                
            
                var textLayer = SymbolLayer(id: "markers-text-layer", source: "markers-source")
                    textLayer.textField = .expression(
                        Exp(.get) { "title" }                  // pull the "title" property
                    )
                    textLayer.textFont = .constant(["DIN Offc Pro Medium", "Arial Unicode MS Regular"])
                    textLayer.textSize = .constant(14)
                    textLayer.textColor = .constant(StyleColor(.black))
                    textLayer.textAnchor = .constant(.top)      // label sits **below** the icon
                textLayer.textOffset = .constant([0, 1.2]) // distance from icon (in em units)
                    textLayer.textHaloColor = .constant(StyleColor(.white))
                    textLayer.textHaloWidth = .constant(2)
                try? mapView.mapboxMap.addLayer(textLayer, layerPosition: .above("markers-icon-layer"))
                
        
    
        
    }
}

