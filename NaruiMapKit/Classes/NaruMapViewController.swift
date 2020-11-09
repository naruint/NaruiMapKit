//
//  NaruMapViewController.swift
//  NaruiMapKit
//
//  Created by Changyeol Seo on 2020/11/09.
//

import UIKit
import MapKit

public class NaruMapViewController: UIViewController {
    
    public var viewModel:NaruMapApiManager.ViewModel? = nil {
        didSet {
            DispatchQueue.main.async {[weak self] in
                for document in self?.viewModel?.documents ?? [] {
                    let pin = MKPointAnnotation()
                    pin.coordinate = document.coordinate
                    pin.title = document.place_name
                    self?.mapView?.addAnnotation(pin)
                }
            }
        }
    }
    public var altitude:CLLocationDistance = 1500
    
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var tableView: UITableView!
    
    public static var viewController : NaruMapViewController {
        if #available(iOS 13.0, *) {
            return
                UIStoryboard(
                    name: "NaruMapViewController",
                    bundle: Bundle(for:NaruMapViewController.self))
                .instantiateViewController(identifier: "root")
        } else {
            return UIStoryboard(
                name: "NaruMapViewController",
                bundle: Bundle(for:NaruMapViewController.self ))
                .instantiateViewController(withIdentifier: "root") as! NaruMapViewController
        }
    }

    public override func viewDidLoad() {
        super.viewDidLoad()
        let camera = MKMapCamera()
        camera.altitude = altitude
        mapView.camera = camera
        if let location = LocationManager.shared.myLocation.last {
            mapView.centerCoordinate = location.coordinate
        }
        mapView.delegate = self
    }
    
}

extension NaruMapViewController : UITableViewDataSource {
    public func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let model = viewModel else {
            return 0
        }
        return model.documents.count
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let model = viewModel else {
            return UITableViewCell()
        }
        let data = model.documents[indexPath.row]
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.textLabel?.text = data.place_name
        cell.detailTextLabel?.text = data.phone
        return cell
    }
    
}

extension NaruMapViewController : UITableViewDelegate {
    
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let coordinate = viewModel?.documents[indexPath.row].coordinate else {
            return
        }
        if let ann = mapView.annotations.filter({ (ann) -> Bool in
            ann.coordinate.longitude == coordinate.longitude
                && ann.coordinate.latitude == coordinate.latitude
        }).first {
            mapView.selectAnnotation(ann, animated: true)
            UIView.animateKeyframes(withDuration: 0.25, delay: 0.0, options: .calculationModeCubic) {[unowned self] in
                mapView.centerCoordinate = coordinate
            } completion: {_ in
                
            }
        }
        
    }
}


extension NaruMapViewController : MKMapViewDelegate {
    public func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        guard let list = viewModel?.documents else {
            return
        }
        if let point = view.annotation as? MKPointAnnotation {
            let index:Int = list.firstIndex { (doc) -> Bool in
                return (doc.coordinate.latitude == point.coordinate.latitude
                            && doc.coordinate.longitude == point.coordinate.longitude)
            } ?? 0
            print(index)
            let indexPath =  IndexPath(row: index, section: 0)
            if tableView.indexPathForSelectedRow != indexPath {
                tableView.selectRow(at: indexPath, animated: true, scrollPosition: .bottom)
            }
        }
    }
}
