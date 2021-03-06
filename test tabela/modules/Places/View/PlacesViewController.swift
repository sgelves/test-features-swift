//
//  PlacesPlacesViewController.swift
//  test-features-swift
//
//  Created by Sergio on 11/06/2019.
//  Copyright © 2019 sgelves. All rights reserved.
//

import UIKit
import Kingfisher
import CoreLocation
import RxSwift
// import RxCocoa

class PlacesViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, ViewToPresePlacesProtocol, Storyboarded, CLLocationManagerDelegate  {
    
    var data: [Local] = []
    
    private var coordinate: CLLocationCoordinate2D?
    
    var locationManager: CLLocationManager = CLLocationManager()
    
    var searchController : UISearchController! = UISearchController(searchResultsController: nil)

    @IBOutlet weak var tableView: UITableView!
    
    // Observables for presenter
    var uiviewDidLoad: PublishSubject<Bool> = PublishSubject<Bool>()
    var loadMoreResultData: PublishSubject<Bool> = PublishSubject<Bool>()
    var resetResultData: PublishSubject<Dictionary<String, Any>> = PublishSubject<Dictionary<String, Any>>()
    var selectedPlace: PublishSubject<Local> = PublishSubject<Local>()
    var uiviewDidFinish: PublishSubject<Bool> = PublishSubject<Bool>()
    
    var presenter: PreseToViewPlacesProtocol!
    
    fileprivate let dispose = DisposeBag()

    // MARK: Life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        self.requestLocation()
        self.createSearhBar()
        
        self.uiviewDidLoad.on(.next(true))
        
        // Subscribe to presenter
        presenter.placesDataChanged.subscribe({ event in
            if (event.element != nil) {
                self.data = event.element!
                self.tableView.reloadData()
            }
        }).disposed(by: dispose)
    }
    
    func createSearhBar() {
        
        self.searchController.searchResultsUpdater = self // changing text event
        self.searchController.obscuresBackgroundDuringPresentation = false
        self.searchController.searchBar.placeholder = "Buscar um local"
        self.searchController.searchBar.delegate = self // search button pressed event
        navigationItem.searchController = self.searchController
        navigationItem.hidesSearchBarWhenScrolling = false
        
        definesPresentationContext = true
        
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
                //self.errorUserCoordinateMessage()
                break
            }
            
        } else {
            // self.enableGPSMessage()
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
        // self.errorUserCoordinateMessage()
    }
    
    /*
    Presenting the results with the qeuried location.
     */
    func setUserCoordinate (coordinate: CLLocationCoordinate2D) {
        self.coordinate = coordinate
        self.resetResultData.on(.next(
            ["latitude": coordinate.latitude, "longitude": coordinate.longitude, "searchString": ""]
            ))
        self.loadMoreResultData.on(.next(true))
    }
    
    func placesHasChanged(places: [Local]) {
        self.data = places
        self.tableView.reloadData()
    }
    
    /**
    UI Table Controller Methods
    **/
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.data.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "resultCell", for: indexPath) as! ResultCellTableViewCell
        let result = data[indexPath.row]
        
        var distance: String
        if result.distance < 1 {
            distance = String(format: "%3d mts", Int(result.distance))
        } else {
            distance = String(format: "%.1f km", result.distance)
        }
        if (result.placeCategoryName != nil && !result.placeCategoryName!.isEmpty) {
            cell.title.text = "\(distance) | \(result.placeCategoryName!)"
        } else {
            cell.title.text = "\(distance)"
        }
        
        cell.name.text = result.placeName
        
        if result.ratingAverage != nil {
            cell.starsLabel.text = String(format: "%.1f", result.ratingAverage!)
        } else {
            cell.starsView.isHidden = true
        }
        
        if (result.placePhoto != nil) {
            cell.thumbnail.kf.setImage(with: URL(string: result.placePhoto!), options: [.diskCacheExpiration(.days(9))])
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let place = data[indexPath.row]
        self.selectedPlace.on(.next(place))
    }
    
    /*
     Infinite scroll functionality
     */
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let offset = scrollView.contentOffset.y
        let contentHeight = scrollView.contentSize.height
        
        if (offset > contentHeight - scrollView.frame.height * 2) && self.coordinate != nil {
            self.loadMoreResultData.on(.next(true))
        }
    }
    
    
    /*
     Restart the model state and query for new data according to the searchString filter
     */
    func filterContentForSearchText(_ searchText: String, scope: String = "All") {
        guard self.coordinate != nil else {
            return
        }
        self.resetResultData.on(.next(
            ["latitude": coordinate!.latitude,
             "longitude": coordinate!.longitude,
             "searchString": self.searchController.searchBar.text!]
            ))
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        self.uiviewDidFinish.on(.next(true))
    }
}

/*
 Delegates methods for the search bar
 */
extension PlacesViewController: UISearchBarDelegate,  UISearchResultsUpdating {
    
    func updateSearchResults(for searchController: UISearchController) {
        if (searchController.searchBar.text!.isEmpty) {
            // Clear the search filter when the model is not empty
            filterContentForSearchText(searchController.searchBar.text!)
        }
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        
        // search only when the search button is hit
        filterContentForSearchText(searchController.searchBar.text!)
    }
}
