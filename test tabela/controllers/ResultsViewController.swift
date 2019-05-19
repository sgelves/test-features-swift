//
//  ResultsViewController.swift
//  test tabela
//
//  Created by user155532 on 5/11/19.
//  Copyright © 2019 sgelves. All rights reserved.
//

import UIKit
import Kingfisher
import CoreLocation

class ResultsViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, CLLocationManagerDelegate, LocaisModel {
    
    @IBOutlet weak var tableView: UITableView!

    var resultData: [Local] = []
    var currentPage: Int = 0
    var isFetchingLoais: Bool = false
    
    private var coordinate: CLLocationCoordinate2D?
    var locationManager: CLLocationManager = CLLocationManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.requestLocation()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return resultData.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "resultCell", for: indexPath) as! ResultCellTableViewCell
        let result = resultData[indexPath.row]
        cell.title.text = result.placeName
        
        if (result.placePhoto != nil) {
            cell.thumbnail.kf.setImage(with: URL(string: result.placePhoto!), options: [.diskCacheExpiration(.days(9))])
        }
        
        return cell
    }
    
    /*
        Infinite scroll functionality
    */
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let offset = scrollView.contentOffset.y
        let contentHeight = scrollView.contentSize.height
        
        if (offset > contentHeight - scrollView.frame.height * 2) && self.coordinate != nil {
            self.getNextPage(latitude: self.coordinate!.latitude, longitude: self.coordinate!.longitude,
                             searchString: "") {
                self.tableView.reloadData()
            }
        }
        
    }
    
    /*
        Requesting location functionality
    */
    func requestLocation () {
        if CLLocationManager.locationServicesEnabled() == true {
            
            switch CLLocationManager.authorizationStatus() {
            case .notDetermined:
                // Request when-in-use authorization initially
                locationManager.requestWhenInUseAuthorization()
                break
                
            case .restricted, .denied:
                // Disable location features, in this case ask for permissions again
                locationManager.requestWhenInUseAuthorization()
                break
                
            case .authorizedWhenInUse, .authorizedAlways:
                // Enable basic location features
                locationManager.desiredAccuracy = kCLLocationAccuracyBest
                locationManager.delegate = self
                locationManager.startUpdatingLocation()
                break
            @unknown default:
                self.errorUserCoordinateMessage()
                break
            }
            
        } else {
            self.enableGPSMessage()
        }
    }
    
    /*
        Responding to request location result
     */
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        self.locationManager.stopUpdatingLocation()
        self.setUserCoordinate(coordinate: locations[0].coordinate)
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        self.errorUserCoordinateMessage()
    }
    
    
    /*
        Presenting the results with the qeuried location.
     */
    func setUserCoordinate (coordinate: CLLocationCoordinate2D) {
        self.coordinate = coordinate
        self.getNextPage(latitude: coordinate.latitude, longitude: coordinate.longitude, searchString: "") {
            self.tableView.reloadData()
        }
    }
    
    /*
        Ask the user for activating the GPS
     */
    func enableGPSMessage () {
        
    }
    
    /*
        Tell the user that there were ane error while getting his location.
     */
    func errorUserCoordinateMessage () {
        
    }
}
