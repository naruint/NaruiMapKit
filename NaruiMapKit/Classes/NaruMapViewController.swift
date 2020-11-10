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
    public var keywords:String = "정신병원"
    
    let ranges:[Int] = [500,1000,2000,4000,8000]
    let rangeTitles:[String] = ["500m", "1km", "2km", "4km","8km"]
    public var viewModels:[NaruMapApiManager.ViewModel] = [] {
        didSet {
            DispatchQueue.main.async {[weak self] in
                for ann in self?.mapView.annotations ?? [] {
                    self?.mapView.removeAnnotation(ann)
                }
                for list in self?.viewModels ?? [] {
                    for document in list.documents {
                        let pin = MKPointAnnotation()
                        pin.coordinate = document.coordinate
                        pin.title = document.place_name
                        self?.mapView?.addAnnotation(pin)
                    }
                }
            }
        }
    }
    public var altitude:CLLocationDistance = 1000
    
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var rangeTextField: UITextField!
    @IBOutlet weak var moreLoadBtn: UIButton!
    
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
        moreLoadBtn.isHidden = true
        moreLoadBtn.rx.tap.bind {[unowned self]_ in
            loadData()
        }.disposed(by: disposeBag)
        
        rangeTextField.setRightButtonDownStyle(disposeBag: disposeBag) { [unowned self](button) in
            rangeTextField.becomeFirstResponder()
        }
    }
    
    @objc func onTouchDone(_ sender:UIBarButtonItem) {
        self.view.endEditing(true)
    }
    
    private var isMovetoMyLocation = false
    private func loadData() {
        // 다 읽어왔으면 더 요청하지 않는다.
        if viewModels.last?.meta.is_end == true {
            return
        }
        NaruMapApiManager.shared.get(query: keywords, radius: Int(altitude), page: viewModels.count + 1) { [weak self](viewModel) in
            guard let s = self else {
                return
            }
            if let model = viewModel {
                s.moreLoadBtn.isHidden = model.meta.is_end == true
                s.viewModels.append(model)
                s.tableView.insertSections(IndexSet(integer: s.tableView.numberOfSections), with: .automatic)
            }
            if self?.isMovetoMyLocation == false {
                self?.moveMyLocation()
                self?.isMovetoMyLocation = true
            }
        }
    }
    
    private func moveMyLocation() {
        if let location = LocationManager.shared.myLocation.last {
            mapView.centerCoordinate = location.coordinate
        }
    }
    
    /** 위치정보로 NaruMapApiManager.Document 찾기 */
    private func findDocumentBy(location:CLLocationCoordinate2D)->NaruMapApiManager.Document? {
        for viewModel in viewModels {
            for doc in viewModel.documents {
                let a = doc.coordinate.latitude == location.latitude
                let b = doc.coordinate.longitude == location.longitude
                if a && b {
                    return doc
                }
            }
        }
        return nil
    }
    /** 위치정보로 IndexPath 찾기*/
    private func findIndexPathBy(location:CLLocationCoordinate2D)->IndexPath? {
        for (a,viewModel) in viewModels.enumerated() {
            for (b,doc) in viewModel.documents.enumerated() {
                if doc.coordinate.latitude == location.latitude && doc.coordinate.longitude == location.longitude {
                    return IndexPath(row: b, section: a)
                }
            }
        }
        return nil
    }
}

extension NaruMapViewController : UITableViewDataSource {
    public func numberOfSections(in tableView: UITableView) -> Int {
        return viewModels.count
    }
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModels[section].documents.count
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let data = viewModels[indexPath.section].documents[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.textLabel?.text = data.place_name
        cell.detailTextLabel?.text = data.phone
        return cell
    }
    
}

extension NaruMapViewController : UITableViewDelegate {
    
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let coordinate = viewModels[indexPath.section].documents[indexPath.row].coordinate
        
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
            tableView.reloadData()
            loadData()
        default:
            break
        }

    }
}


