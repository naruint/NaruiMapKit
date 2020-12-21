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
import PullableSheet
extension PullableSheet {
    var isBlurHide:Bool {
        set {
            for view in view.subviews {
                if let b = view as? UIVisualEffectView {
                    b.isHidden = newValue
                }
            }
        }
        get {
            for view in view.subviews {
                if let b = view as? UIVisualEffectView {
                    return b.isHidden
                }
            }
            return false
        }
    }
}

public class NaruMapViewController: UIViewController {
    let listVC = NaruMapSearchResultTableViewController.viewController
    weak var pullableSheet:PullableSheet? = nil
    @IBOutlet var customSheetHeaderView: UIView!

    
    enum Keyword : String {
        case total = "정신병원,정신상담센터"
        case first = "정신병원"
        case second = "정신상담센터"
    }
    
    var keyword:Keyword = .total
    
    public var keywords:String {
        return keyword.rawValue
    }
    
    var keywordArray:[String] {
        self.keywords.components(separatedBy: ",")
    }

    @IBOutlet var keywordSelectButtons:[UIButton]!
    
    @IBOutlet weak var moveToMyLocationButton: UIButton!
    
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
            listVC.data = data
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
                listVC.tableView.reloadData()
            }
        }
    }
    
    public var altitude:CLLocationDistance = 1000
    
    @IBOutlet weak var mapView: MKMapView!
    
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
        
        loadData()
        updateUI()
        for (index,btn) in keywordSelectButtons.enumerated() {
            btn.rx.tap.bind { [unowned self](_) in
                switch index {
                case 0:
                    keyword = .total
                case 1:
                    keyword = .first
                case 2:
                    keyword = .second
                default:
                    break
                }
                reload()
                updateUI()
            }.disposed(by: disposeBag)
        }
        
        listVC.delegate = self
        moveToMyLocationButton.setBackgroundImage(UIColor.white.circleImage(diameter: moveToMyLocationButton.frame.size.width), for: .normal)
        
        customSheetHeaderView.frame.size = CGSize(width: UIScreen.main.bounds.width, height: 20)
        
        let sheet = PullableSheet(content: listVC, topBarStyle: .custom(customSheetHeaderView))
        sheet.add(to: self)
        sheet.snapPoints = [.custom(y: 250),
                            .custom(y: UIScreen.main.bounds.height - 300)]
        sheet.scroll(toY: 300,duration: 0.25)
        sheet.isBlurHide = true
        sheet.view.backgroundColor = UIColor.white
        pullableSheet = sheet
        moveToMyLocationButton.rx.tap.bind {[unowned self] (_) in
            moveMyLocation()
        }.disposed(by: disposeBag)
    }
    
    func updateUI() {
        for btn in keywordSelectButtons {
            btn.isSelected = false
        }
        switch keyword {
        case .total:
            keywordSelectButtons[0].isSelected = true
        case .first:
            keywordSelectButtons[1].isSelected = true
        case .second:
            keywordSelectButtons[2].isSelected = true
        }
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
    
    func reload() {
        viewModels.removeAll()
        loadData()
    }
    
    func loadData() {
    
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
            UIView.animate(withDuration: 0.25, delay: 0, options: .curveEaseInOut) {[weak self]in
                self?.mapView.centerCoordinate = location.coordinate
            } completion: { _ in
                
            }

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




extension NaruMapViewController : MKMapViewDelegate {
    public func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        if let point = view.annotation as? MKPointAnnotation {
            let indexPath = findIndexPathBy(location: point.coordinate)
            listVC.tableView.selectRow(at: indexPath, animated: true, scrollPosition: .top)
        }
    }
}


extension NaruMapViewController : NaruMapSearchResultTableViewControllerDelegate {
    func mapSearchResultSelect(data: NaruMapApiManager.Document, indexPath: IndexPath) {
        let coordinate = data.coordinate
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