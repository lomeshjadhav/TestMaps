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
        let coordinates = [
          
            CLLocationCoordinate2D(latitude: 51.52221, longitude: -0.12705), // london
            CLLocationCoordinate2D(latitude: 51.51618, longitude: -3.15730), //Cardiff
            CLLocationCoordinate2D(latitude: 54.65317, longitude: -5.93219), //Belfast
            CLLocationCoordinate2D(latitude: 55.95360, longitude: -3.18818) //Edinburgh
            
           
        ]
        
        // Add marker image
        try? mapView.mapboxMap.addImage(UIImage(named: "dest-pin")!, id: "marker-icon")
        
        // Create features for all markers
        var features = [Feature]()
        for coordinate in coordinates {
            let feature = Feature(geometry: Point(coordinate))
            features.append(feature)
        }
        
        
        // Add source with all markers
        var source = GeoJSONSource(id: "markers-source")
        source.data = .featureCollection(FeatureCollection(features: features))
        try? mapView.mapboxMap.addSource(source)
        
        
        
        // Fit camera to show all markers
        let cameraOptions = try? mapView.mapboxMap.camera(
            for: coordinates,
            camera: CameraOptions(),
            coordinatesPadding: UIEdgeInsets(top: 50, left: 50, bottom: 50, right: 50),
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
        
    
        
    }
}

