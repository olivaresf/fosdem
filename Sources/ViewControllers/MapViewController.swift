import MapKit

protocol MapViewControllerDelegate: AnyObject {
    func mapViewController(_ mapViewController: MapViewController, didSelect building: Building)
}

final class MapViewController: UIViewController {
    weak var delegate: MapViewControllerDelegate?

    private let buildings = Building.allBuildings

    private lazy var mapView = MKMapView()

    override func loadView() {
        view = mapView
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        mapView.delegate = self
        mapView.region = .university
        mapView.tintColor = .fos_label
        mapView.showsPointsOfInterest = false

        let overlays = buildings.map { building in building.polygon }
        mapView.addOverlays(overlays)

        if #available(iOS 11.0, *) {
            mapView.register(MKMarkerAnnotationView.self, forAnnotationViewWithReuseIdentifier: MKMarkerAnnotationView.reuseIdentifier)
        }

        if #available(iOS 13.0, *) {
            mapView.cameraBoundary = MKMapView.CameraBoundary(coordinateRegion: .universityBoundary)
        }

        for building in buildings {
            mapView.addAnnotation(building)
        }

        let tapAction = #selector(didTapMap(_:))
        let tapRecognizer = UITapGestureRecognizer(target: self, action: tapAction)
        mapView.addGestureRecognizer(tapRecognizer)
    }

    @objc private func didTapMap(_ recognizer: UITapGestureRecognizer) {
        let location = recognizer.location(in: recognizer.view)
        let coordinate = mapView.convert(location, toCoordinateFrom: mapView)

        let origin = MKMapPoint(coordinate)
        let size = MKMapSize(width: .leastNonzeroMagnitude, height: .leastNonzeroMagnitude)
        let rect = MKMapRect(origin: origin, size: size)

        if let building = buildings.first(where: { building in building.polygon.intersects(rect) }) {
            delegate?.mapViewController(self, didSelect: building)
        }
    }
}

extension MapViewController: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        let renderer = MKPolygonRenderer(overlay: overlay)
        renderer.fillColor = mapView.tintColor.withAlphaComponent(0.3)
        renderer.strokeColor = mapView.tintColor
        renderer.lineWidth = 1
        return renderer
    }

    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        guard #available(iOS 11.0, *), let building = annotation as? Building else {
            return nil
        }

        let annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: MKMarkerAnnotationView.reuseIdentifier, for: annotation) as! MKMarkerAnnotationView
        annotationView.markerTintColor = mapView.tintColor
        annotationView.glyphText = building.glyph
        return annotationView
    }
}

private extension MKCoordinateRegion {
    static var university: MKCoordinateRegion {
        let center = CLLocationCoordinate2D(latitude: 50.813028067326343, longitude: 4.381335908547527)
        let span = MKCoordinateSpan(latitudeDelta: 0.0066549403022264642, longitudeDelta: 0.0060411691513593269)
        return .init(center: center, span: span)
    }

    static var universityBoundary: MKCoordinateRegion {
        let center = CLLocationCoordinate2D(latitude: 50.812996597684815, longitude: 4.38132229168761)
        let span = MKCoordinateSpan(latitudeDelta: 0.0050337033797305253, longitudeDelta: 0.0045694524231123523)
        return .init(center: center, span: span)
    }
}
