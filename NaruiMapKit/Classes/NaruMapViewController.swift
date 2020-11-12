//
//  NaruMapViewController.swift
//  NaruiMapKit
//
//  Created by Changyeol Seo on 2020/11/09.
//

import UIKit
import MapKit
import RxCocoa
import RxSwift

public class NaruMapViewController: UIViewController {
    public var keywords:String = "정신병원,정신상담센터"
    var keywordArray:[String] {
        self.keywords.components(separatedBy: ",")
    }
    
    @IBOutlet weak var keywordLabel: UILabel!
    
    public var ranges:[Int] = [500,1000,2000,4000,8000]
    public var rangeTitles:[String] = ["500m", "1km", "2km", "4km","8km"]
    public var viewModels:[String : [NaruMapApiManager.ViewModel]] = [:]

    
    var data:[NaruMapApiManager.Document] = [] {
        didSet {
            data = data.sorted { (a, b) -> Bool in
                if let c = a.getDistance(), let d = b.getDistance() {
                    return c < d
                }
                return false
            }
            DispatchQueue.main.async {[unowned self] in
                for ann in mapView.annotations  {
                    mapView.removeAnnotation(ann)
                }
                for document in data {
                    let pin = MKPointAnnotation()
                    pin.coordinate = document.coordinate
                    pin.title = document.place_name
                    mapView.addAnnotation(pin)
                }
            }
        }
    }
    
    public var altitude:CLLocationDistance = 1000
    
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var rangeTextField: UITextField!
    
    let rangePickerView = UIPickerView()
    let camera = MKMapCamera()

    let disposeBag = DisposeBag()
    
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
        camera.distance = altitude * 2
        mapView.camera = camera
        mapView.delegate = self
        rangePickerView.dataSource = self
        rangePickerView.delegate = self
        rangeTextField.text = "\(Int(altitude))"
        rangeTextField.inputView = rangePickerView
        rangeTextField.setDoneInputView(title: "done", target: self, action: #selector(self.onTouchDone(_:)))
        if let index = ranges.firstIndex(where: { a -> Bool in
            return a == Int(altitude)
        }) {
            rangePickerView.selectRow(index, inComponent: 0, animated: false)
        }
        loadData()

        rangeTextField.setRightButtonDownStyle(disposeBag: disposeBag) { [unowned self](button) in
            rangeTextField.becomeFirstResponder()
        }
        keywordLabel.text = keywords
//        for key in keywordArray {
//            viewModels[key] = Array<NaruMapApiManager.ViewModel>()
//        }
    }
    
    @objc func onTouchDone(_ sender:UIBarButtonItem) {
        self.view.endEditing(true)
    }
    
    private var isMovetoMyLocation = false
    
    
    private var loadedKeywordCount:Int {
        var count = 0
        for a in viewModels.values {
            if a.last?.meta.is_end == true {
                count += 1
            }
        }
        if keywordArray.count < count {
            return keywordArray.count
        }
        return count
    }
    
    private func loadData() {
    
        // 다 읽어왔으면 더 요청하지 않는다.
        if keywordArray.count == loadedKeywordCount {
            self.data.removeAll()
            for a in viewModels.values {
                for viewModel in a {
                    for doc in viewModel.documents {
                        self.data.append(doc)
                    }
                }
            }
            self.tableView.reloadData()
            return
        }
        let key = keywordArray[loadedKeywordCount]
        let page = (viewModels[key]?.count ?? 0) + 1
        print(page)
        
        NaruMapApiManager.shared.get(query: key, radius: Int(altitude), page: page) { [weak self](viewModel) in
            guard let s = self else {
                return
            }
            print(viewModel ?? "")
            
            if let model = viewModel {
                if s.viewModels[key] == nil {
                    s.viewModels[key] = Array<NaruMapApiManager.ViewModel>()
                }
                s.viewModels[key]?.append(model)
            }
            if self?.isMovetoMyLocation == false {
                self?.moveMyLocation()
                self?.isMovetoMyLocation = true
            }
            self?.loadData()
        }
    }
    
    private func moveMyLocation() {
        if let location = LocationManager.shared.myLocation.last {
            mapView.centerCoordinate = location.coordinate
        }
    }
    
    /** 위치정보로 NaruMapApiManager.Document 찾기 */
    private func findDocumentBy(location:CLLocationCoordinate2D)->NaruMapApiManager.Document? {
        for doc in data {
            let a = doc.coordinate.latitude == location.latitude
            let b = doc.coordinate.longitude == location.longitude
            if a && b {
                return doc
            }
        }
        return nil
    }
    /** 위치정보로 IndexPath 찾기*/
    private func findIndexPathBy(location:CLLocationCoordinate2D)->IndexPath? {
        for (b,doc) in data.enumerated() {
            if doc.coordinate.latitude == location.latitude && doc.coordinate.longitude == location.longitude {
                return IndexPath(row: b, section: 0)
            }
        }
        return nil
    }
}

extension NaruMapViewController : UITableViewDataSource {
    public func numberOfSections(in tableView: UITableView) -> Int {
        return data.count > 0 ? 1 : 0
    }
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return data.count
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let data = self.data[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.textLabel?.text = data.place_name
        cell.detailTextLabel?.text = data.phone
        cell.detailTextLabel?.text?.append(" \(Int(data.getDistance() ?? 0)) m")
        return cell
    }
    
}

extension NaruMapViewController : UITableViewDelegate {
    
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let coordinate = data[indexPath.row].coordinate
        
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
        if let point = view.annotation as? MKPointAnnotation {
            let indexPath = findIndexPathBy(location: point.coordinate)
            if tableView.indexPathForSelectedRow != indexPath {
                tableView.selectRow(at: indexPath, animated: true, scrollPosition: .bottom)
            }
        }
    }
}

extension NaruMapViewController : UIPickerViewDataSource {
    public func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    public func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        switch pickerView {
        case rangePickerView:
            return ranges.count
        default:
            return 0
        }
    }
    
}

extension NaruMapViewController : UIPickerViewDelegate {
    public func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        switch pickerView {
        case rangePickerView:
            return rangeTitles[row]
        default:
            return nil
        }
    }
    public func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        switch pickerView {
        case rangePickerView:
            let value = ranges[row]
            rangeTextField.text = "\(value)"
            altitude = CLLocationDistance(value)
            UIView.animate(withDuration: 0.25) {[weak self]in
                self?.camera.distance = CLLocationDistance(value) * 2
            }
            
            viewModels.removeAll()
            data.removeAll()
            tableView.reloadData()
            loadData()
        default:
            break
        }

    }
}


