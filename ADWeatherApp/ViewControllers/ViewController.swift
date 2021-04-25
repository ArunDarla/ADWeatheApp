//
//  ViewController.swift
//  ADWeatherApp
//
//  Created by VIPadm on 24/04/21.
//

import UIKit
import MapKit
import CoreLocation

class ViewController: UIViewController, UIGestureRecognizerDelegate, CLLocationManagerDelegate {
    
    @IBOutlet weak var mapView: MKMapView!
    let pointAnnot = MKPointAnnotation()
    var locationsArr = [LocationDetails]()
    
    var isSearchStatus: Bool = false
    var filterArr = [LocationDetails]()
    
    var placeName: String = ""
    var countryName: String = ""
    var coordinate = CLLocationCoordinate2D()
    
    @IBOutlet weak var citiesTV: UITableView!
    
    let locManager = CLLocationManager()
    let favStar = UIButton(type: .contactAdd)
    
    @IBOutlet weak var searchTF: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        citiesTV.tableFooterView = UIView(frame: CGRect.zero)
        citiesTV.backgroundColor = UIColor.clear
        
        self.title = "Weather app"
        
        mapView.showsUserLocation = true
        mapView.delegate = self
        mapView.mapType = .standard
        
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
        
        favStar.addTarget(self, action:#selector(FavoraiteButtonAction), for:.touchUpInside)
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        self.navigationController?.navigationBar.isHidden = false
    }
    
    @IBAction func SettingsButtonAction(sender: UIButton){
        
        let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
        let settingsVC = storyBoard.instantiateViewController(withIdentifier: "SettingsViewController") as! SettingsViewController
        self.navigationController?.pushViewController(settingsVC, animated: true)
        
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
        isSearchStatus = false
        citiesTV.reloadData()
        
        
        
    }
    
    @objc func mapTapped(tapGesture: UITapGestureRecognizer) {
        
        let annotations = mapView.annotations.filter {
            $0 !== self.mapView.userLocation
        }
        mapView.removeAnnotations(annotations)
        let selectedPoint = tapGesture.location(in: mapView)
        coordinate = mapView.convert(selectedPoint, toCoordinateFrom: mapView)
        
        let location = CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)
        let geoCoder = CLGeocoder()
        geoCoder.reverseGeocodeLocation(location) { [self] (geoCoderPlaces, error) in
            
            var placeMark: CLPlacemark!
            
            placeMark = geoCoderPlaces?[0]
            
            if (placeMark.addressDictionary!["City"] != nil) {
                placeName = placeMark.addressDictionary!["City"] as! String
            }else{
                placeName = placeMark.addressDictionary!["Name"] as! String
            }
            countryName = placeMark.country  ?? ""
            
            if placeName.count == 0 {
                return
            }
            if countryName.count == 0{
                pointAnnot.title = placeName
            }else{
                pointAnnot.title = placeName + ", " + countryName
            }
            
            pointAnnot.coordinate = coordinate
            mapView.addAnnotation(pointAnnot)
            
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
    
}

extension ViewController: MKMapViewDelegate  {
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        
        guard annotation is MKPointAnnotation else { return nil }
        
        let identifier = "Annotation"
        
        let annotationView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: identifier)
        annotationView.canShowCallout = true
        annotationView.isEnabled = true
        annotationView.rightCalloutAccessoryView = favStar
        
        return annotationView
        
    }
    func mapView(_ mapView: MKMapView, didAdd views: [MKAnnotationView]) {
        self.mapView.selectAnnotation(self.mapView.annotations[0], animated: true)
    }
    func mapView(_ mapView: MKMapView, didDeselect view: MKAnnotationView) {
        perform(#selector(reSelectAnnotationIfNoneSelected(_:)), with: view.annotation, afterDelay: 0)
    }
    
    @objc func reSelectAnnotationIfNoneSelected(_ annotation: MKAnnotation) {
        if mapView.selectedAnnotations.count == 0 {
            mapView.selectAnnotation(annotation, animated: false)
        }
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
        if isSearchStatus {
            return filterArr.count
        }else{
            return locationsArr.count
        }
        
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CityTableViewCell", for: indexPath) as! CityTableViewCell
        
        cell.cellBV.layer.cornerRadius = 6.0
        cell.cellBV.layer.borderWidth = 0.4
        cell.cellBV.layer.borderColor = UIColor.lightGray.cgColor
        if isSearchStatus {
            cell.cityLbl.text = filterArr[indexPath.row].localityName + ", " + locationsArr[indexPath.row].country
        }else{
            cell.cityLbl.text = locationsArr[indexPath.row].localityName + ", " + locationsArr[indexPath.row].country
        }
        
        cell.favorateBtn.tag = indexPath.row
        cell.favorateBtn.addTarget(self, action: #selector(favButtonTapped(sender:)), for: .touchUpInside)
        
        return cell
    }
    
    @objc func favButtonTapped(sender: UIButton ){
        
        let index = sender.tag
        if isSearchStatus {
            filterArr.remove(at: index)
        }else{
            locationsArr.remove(at: index)
        }
        
        citiesTV.reloadData()
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
        let forcastVC = storyBoard.instantiateViewController(withIdentifier: "CitiesForecastViewController") as! CitiesForecastViewController
        if isSearchStatus {
            forcastVC.locality = filterArr[indexPath.row].localityName
            forcastVC.country = filterArr[indexPath.row].country
        }else{
            forcastVC.locality = locationsArr[indexPath.row].localityName
            forcastVC.country = locationsArr[indexPath.row].country
        }
        
        self.navigationController?.pushViewController(forcastVC, animated: true)
        
        
    }
    
}

extension ViewController: UITextFieldDelegate {
    
    
    public func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool{
        
        var searchStr: String = ""
        
        let text = searchTF.text
        let textRange = Range(range, in: text!)
        searchStr = text!.replacingCharacters(in: textRange!, with: string)
        
        if searchStr.elementsEqual("") {
            isSearchStatus = false
            citiesTV.reloadData()
            return true
        }
        isSearchStatus = true
        getSearchArrayContains(searchText: searchStr)
        
        
        return true
    }
    
    func getSearchArrayContains(searchText: String){
        
        print(searchText)
        filterArr = locationsArr.filter { $0.localityName.lowercased().hasPrefix(searchText.lowercased()) }
        citiesTV.reloadData()
        
    }
    
}
