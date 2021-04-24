//
//  ViewController.swift
//  ADWeatherApp
//
//  Created by VIPadm on 24/04/21.
//

import UIKit
import MapKit
import CoreLocation

class ViewController: UIViewController, MKMapViewDelegate, UIGestureRecognizerDelegate, CLLocationManagerDelegate {

    @IBOutlet weak var mapView: MKMapView!
    let pointAnnot = MKPointAnnotation()
    var locationsArr = [LocationDetails]()
    var placeName: String = ""
    var countryName: String = ""
    
    @IBOutlet weak var citiesTV: UITableView!
    
    let starBtn = UIButton(type: .detailDisclosure)
    let locManager = CLLocationManager()
    
    @IBOutlet weak var locAnnotationBV: UIView!
    
    @IBOutlet weak var locName: UILabel!
    @IBOutlet weak var favStar: UIButton!
    @IBOutlet weak var closeBtn: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        self.title = "Weather app"
        locAnnotationBV.layer.cornerRadius = 6.0
        locAnnotationBV.layer.borderWidth = 0.4
        locAnnotationBV.layer.borderColor = UIColor.darkGray.cgColor
        
        closeBtn.layer.cornerRadius = 8.0
        closeBtn.layer.borderWidth = 0.4
        closeBtn.layer.borderColor = UIColor.red.cgColor
        
        
        mapView.showsUserLocation = true
        mapView.delegate = self
        mapView.mapType = .standard
        mapView.isZoomEnabled = true
        mapView.isScrollEnabled = true
        
        self.locManager.requestWhenInUseAuthorization()
        citiesTV.register(UINib(nibName: "CityTableViewCell", bundle: nil), forCellReuseIdentifier: "CityTableViewCell")
        
        if CLLocationManager.locationServicesEnabled() {
            locManager.delegate = self
            locManager.desiredAccuracy = kCLLocationAccuracyBest
            locManager.startUpdatingLocation()
        }
        
        let tapGesture:UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(mapTapped(tapGesture:)))
        tapGesture.numberOfTapsRequired = 1
        tapGesture.delegate = self
        mapView.addGestureRecognizer(tapGesture)
        
        if let coor = mapView.userLocation.location?.coordinate{
            mapView.setCenter(coor, animated: true)
        }
        
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        locAnnotationBV.isHidden = true
    }
    
    @IBAction func closeButtonAction(sender: UIButton){
        
        let annotations = mapView.annotations.filter {
            $0 !== self.mapView.userLocation
        }
        mapView.removeAnnotations(annotations)
        citiesTV.reloadData()
        locAnnotationBV.isHidden = true
       
    }
    
    @IBAction func FavoraiteButtonAction(sender: UIButton){
        
        let locationsDic = LocationDetails.init(localityName: placeName, country: countryName )
        
        let indexOfLoc = locationsArr.firstIndex{$0.localityName == locationsDic.localityName}

        if let availIndex = indexOfLoc {
            locationsArr.remove(at: availIndex)
        }else{
            locationsArr.append(locationsDic)
        }
        let annotations = mapView.annotations.filter {
            $0 !== self.mapView.userLocation
        }
        mapView.removeAnnotations(annotations)
        locAnnotationBV.isHidden = true
        print(locationsArr)
        citiesTV.reloadData()

        
        
    }
    
    @objc func mapTapped(tapGesture: UITapGestureRecognizer) {
        
        let annotations = mapView.annotations.filter {
            $0 !== self.mapView.userLocation
        }
        mapView.removeAnnotations(annotations)
        locAnnotationBV.isHidden = true
        let selectedPoint = tapGesture.location(in: mapView)
        let coordinate = mapView.convert(selectedPoint, toCoordinateFrom: mapView)
        pointAnnot.coordinate = coordinate
        mapView.addAnnotation(pointAnnot)
        
        let location = CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)
        let geoCoder = CLGeocoder()
        geoCoder.reverseGeocodeLocation(location) { [self] (geoCoderPlaces, error) in
            
            if let places = geoCoderPlaces {
                locAnnotationBV.isHidden = false
                let location = places.last
                placeName = location?.locality ?? ""
                countryName = location?.country ?? ""
                locName.text = placeName + ", " + countryName
                if locationsArr.count != 0 {
                    let indexOfLoc = locationsArr.firstIndex{$0.localityName == placeName}
                    if indexOfLoc != nil {
                        favStar.setImage( UIImage(systemName: "star.fill"), for: .normal)
                    }else{
                        favStar.setImage( UIImage(systemName: "star"), for: .normal)
                    }
                }else{
                    favStar.setImage( UIImage(systemName: "star"), for: .normal)
                }
            }
            
        }
        //mapView.region.span.latitudeDelta/0.5
        let mpCrd = MKCoordinateRegion(center: location.coordinate, latitudinalMeters: distanceSpain, longitudinalMeters: distanceSpain)
        mapView.setRegion(mpCrd, animated: true)
        
    }
    

}

extension ViewController {
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        guard annotation is MKPointAnnotation else { return nil }

        let identifier = "Annotation"
        var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier)

        if annotationView == nil {
            annotationView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: identifier)
            annotationView!.canShowCallout = true
        } else {
            annotationView!.annotation = annotation
        }
        
        locAnnotationBV.isHidden = false
        annotationView!.rightCalloutAccessoryView = starBtn
        annotationView!.canShowCallout = true
        return annotationView
    }
    func mapView(_ mapView: MKMapView, didAdd views: [MKAnnotationView]) {
        if let annotation = views.first(where: { $0.reuseIdentifier == "Annotation" })?.annotation {
            mapView.selectAnnotation(annotation, animated: true)
        }
    }

    func bringMyAnnotationToFront(){
        
        if let myAnnotation = mapView.annotations.first(where: { $0 is MKPointAnnotation })
        {
            mapView.selectAnnotation(myAnnotation, animated: true)
        }
    }
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView){
        bringMyAnnotationToFront()
    }
    func mapView(_ mapView: MKMapView, didDeselect: MKAnnotationView){

    }
    
}

extension ViewController: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 74
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        locationsArr.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CityTableViewCell", for: indexPath) as! CityTableViewCell
        
        cell.cellBV.layer.cornerRadius = 6.0
        cell.cellBV.layer.borderWidth = 0.4
        cell.cellBV.layer.borderColor = UIColor.lightGray.cgColor
        cell.cityLbl.text = locationsArr[indexPath.row].localityName + ", " + locationsArr[indexPath.row].country
        cell.favorateBtn.tag = indexPath.row
        cell.favorateBtn.addTarget(self, action: #selector(favButtonTapped(sender:)), for: .touchUpInside)
        
        return cell
    }
    
    @objc func favButtonTapped(sender: UIButton ){
        
        let index = sender.tag
        locationsArr.remove(at: index)
        citiesTV.reloadData()
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
    }
    
}

