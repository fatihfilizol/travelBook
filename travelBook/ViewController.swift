//
//  ViewController.swift
//  travelBook
//
//  Created by Fatih Filizol on 8.08.2022.
//

import UIKit
import MapKit
import CoreLocation
import CoreData

class ViewController: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate {

    
    
    @IBOutlet weak var txtComment: UITextField!
    @IBOutlet weak var txtName: UITextField!
    @IBOutlet weak var mapView: MKMapView!
    
    
    var locationManager = CLLocationManager()
    var choosenLatitude = Double()
    var choosenLongitude = Double()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        mapView.delegate = self
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
        
        
        let gestureRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(chooseLocation(gestureRecognizer:)))
        gestureRecognizer.minimumPressDuration = 2
        mapView.addGestureRecognizer(gestureRecognizer)
        
        let gestureRecognizerKeyboard = UITapGestureRecognizer(target: self, action: #selector(hideKeyboard))
        view.addGestureRecognizer(gestureRecognizerKeyboard)
    }
    
    @objc func hideKeyboard(){
        view.endEditing(true)
    }
    
    @objc func chooseLocation(gestureRecognizer: UILongPressGestureRecognizer){
        if gestureRecognizer.state == .began{
            let touchedPoint = gestureRecognizer.location(in: self.mapView)
            let touchCoordinates = self.mapView.convert(touchedPoint, toCoordinateFrom: self.mapView)
            
            choosenLatitude = touchCoordinates.latitude
            choosenLongitude = touchCoordinates.longitude
            
            
            let annotation = MKPointAnnotation()
            annotation.coordinate = touchCoordinates
            annotation.title = txtName.text
            annotation.subtitle = txtComment.text
            self.mapView.addAnnotation(annotation)
        }
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let location = CLLocationCoordinate2D(latitude: locations[0].coordinate.latitude, longitude: locations[0].coordinate.longitude)
        let span = MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1)
        let region = MKCoordinateRegion(center: location, span: span)
        mapView.setRegion(region, animated: true)
    }
    
    @IBAction func btnSave(_ sender: Any) {
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        
        let newPlace = NSEntityDescription.insertNewObject(forEntityName: "Places", into: context)
        
        newPlace.setValue(txtName.text, forKey: "title")
        newPlace.setValue(txtComment.text, forKey:  "subtitle")
        newPlace.setValue(choosenLongitude, forKey: "longitude")
        newPlace.setValue(choosenLatitude, forKey: "latitude")
        newPlace.setValue(UUID(), forKey: "id")
        
        do{
            try context.save()
            print("Success")
        }catch{
            print("Error")
        }
        
    }
    
}

