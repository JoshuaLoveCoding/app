//
//  NearestTableViewController.swift
//  MetroExplorerApp
//
//  Created by Joshua on 12/5/18.
//  Copyright © 2018 Joshua. All rights reserved.
//

import UIKit
import MBProgressHUD
import CoreLocation

class NearestTableViewController: UITableViewController {
    var lat: Double = 0
    var lon: Double = 0
    let wmataAPIManager = WMATAAPIManager()
    let locationDetector = LocationDetector()
    
    var stations = [Station]() {
        didSet {
            tableView.reloadData()
        }
    }
    
    var stationsNew = [Station]() {
        didSet {
            tableView.reloadData()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        wmataAPIManager.delegate = self
        locationDetector.delegate = self
        fetchStation()
    }
    
    private func fetchStation() {
        MBProgressHUD.showAdded(to: self.view, animated: true)
        locationDetector.findLocation()
    }
    
    // MARK: - Table view data source
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return stationsNew.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "stationCell", for: indexPath) as! StationsTableViewCell
        
        let station = stationsNew[indexPath.row]
        
        cell.stationNameLabel.text = station.name
        cell.stationAddressLabel.text = station.address
        
        if(station.lineCode1 == "RD") {
            cell.lineCodeImage1.image = UIImage(named:"red.png")
        } else if (station.lineCode1 == "BL") {
            cell.lineCodeImage1.image = UIImage(named:"blue.png")
        } else if (station.lineCode1 == "GR") {
            cell.lineCodeImage1.image = UIImage(named:"green.png")
        } else if (station.lineCode1 == "SV") {
            cell.lineCodeImage1.image = UIImage(named:"grey.png")
        } else if (station.lineCode1 == "YL") {
            cell.lineCodeImage1.image = UIImage(named:"yellow.png")
        } else if (station.lineCode1 == "OR") {
            cell.lineCodeImage1.image = UIImage(named:"orange.png")
        }
        
        if(station.lineCode2 == "RD") {
            cell.lineCodeImage2.image = UIImage(named:"red.png")
        } else if (station.lineCode2 == "BL") {
            cell.lineCodeImage2.image = UIImage(named:"blue.png")
        } else if (station.lineCode2 == "GR") {
            cell.lineCodeImage2.image = UIImage(named:"green.png")
        } else if (station.lineCode2 == "SV") {
            cell.lineCodeImage2.image = UIImage(named:"grey.png")
        } else if (station.lineCode2 == "YL") {
            cell.lineCodeImage2.image = UIImage(named:"yellow.png")
        } else if (station.lineCode2 == "OR") {
            cell.lineCodeImage2.image = UIImage(named:"orange.png")
        } else {
            cell.lineCodeImage2.image = UIImage(named:"white.png")
        }
        
        if(station.lineCode3 == "RD") {
            cell.lineCodeImage3.image = UIImage(named:"red.png")
        } else if (station.lineCode3 == "BL") {
            cell.lineCodeImage3.image = UIImage(named:"blue.png")
        } else if (station.lineCode3 == "GR") {
            cell.lineCodeImage3.image = UIImage(named:"green.png")
        } else if (station.lineCode3 == "SV") {
            cell.lineCodeImage3.image = UIImage(named:"grey.png")
        } else if (station.lineCode3 == "YL") {
            cell.lineCodeImage3.image = UIImage(named:"yellow.png")
        } else if (station.lineCode3 == "OR") {
            cell.lineCodeImage3.image = UIImage(named:"orange.png")
        } else {
            cell.lineCodeImage3.image = UIImage(named:"white.png")
        }
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        performSegue(withIdentifier: "segueNearest", sender: indexPath.row)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        //pass the data to your next view controller
        
        let row = sender as! Int
        
        let vc = segue.destination as! LandmarksViewController
        vc.station = stationsNew[row]
    }
}

extension NearestTableViewController: LocationDetectorDelegate {
    func locationDetected(latitude: Double, longitude: Double) {
        self.lat = latitude
        self.lon = longitude
        wmataAPIManager.fetchStations()
    }
    
    func locationNotDetected() {
        print("no location found :(")
        DispatchQueue.main.async {
            MBProgressHUD.hide(for: self.view, animated: true)
            
            //TODO: Show a AlertController with error
        }
    }
}

extension NearestTableViewController: FetchStationsDelegate {
    func stationsFound(_ stations: [Station]) {
        print("stations found - here they are in the controller!")
        DispatchQueue.main.async {
            self.stations = stations
            var dis: Double = 999999999
            var sta = Station(name: "", address: "", lineCode1: "", lineCode2: "", lineCode3: "", lat: -1, lon: -1)
            for ele in stations {
                if ((CLLocation(latitude: ele.lat, longitude: ele.lon).distance(from: CLLocation(latitude: self.lat, longitude: self.lon))) < dis) {
                    dis = CLLocation(latitude: ele.lat, longitude: ele.lon).distance(from: CLLocation(latitude: self.lat, longitude: self.lon))
                    sta = ele
                }
            }
            if (self.stationsNew.count == 0) {
                self.stationsNew.append(sta)
            }
            MBProgressHUD.hide(for: self.view, animated: true)
        }
    }
    
    func stationsNotFound(reason: WMATAAPIManager.FailureReason) {
        DispatchQueue.main.async {
            MBProgressHUD.hide(for: self.view, animated: true)
            
            let alertController = UIAlertController(title: "Problem fetching stations", message: reason.rawValue, preferredStyle: .alert)
            
            switch(reason) {
            case .noResponse:
                let retryAction = UIAlertAction(title: "Retry", style: .default, handler: { (action) in
                    self.fetchStation()
                })
                
                let cancelAction = UIAlertAction(title: "Cancel", style: .default, handler:nil)
                
                alertController.addAction(cancelAction)
                alertController.addAction(retryAction)
                
            case .non200Response, .noData, .badData:
                let okayAction = UIAlertAction(title: "Okay", style: .default, handler:nil)
                
                alertController.addAction(okayAction)
            }
            
            self.present(alertController, animated: true, completion: nil)
        }
    }
}
