//
//  NaruMapSearchResultTableViewController.swift
//  NaruiMapKit
//
//  Created by Changyeol Seo on 2020/12/21.
//

import UIKit
import MapKit
import NaruiUIComponents
import RxCocoa
import RxSwift
protocol NaruMapSearchResultTableViewControllerDelegate : class {
    func mapSearchResultSelect(data:NaruMapApiManager.Document, indexPath:IndexPath)
}

class NaruMapSearchResultTableViewController: UITableViewController {
    static var viewController :NaruMapSearchResultTableViewController {
        let bundle = Bundle(for:NaruMapSearchResultTableViewController.self)
        if #available(iOS 13.0, *) {
            return UIStoryboard(name: "NaruMapViewController", bundle: bundle).instantiateViewController(identifier: "result")
        } else {
            return UIStoryboard(name: "NaruMapViewController", bundle: bundle).instantiateViewController(withIdentifier: "result") as!
                NaruMapSearchResultTableViewController
        }
    }
    
    @IBOutlet weak var emptyImageView: UIImageView!
    @IBOutlet var emptyView: UIView!
    @IBOutlet var headerView: UIView!
    @IBOutlet weak var headerFirstLabel: UILabel!
    @IBOutlet weak var headerTextField: UITextField!
    @IBOutlet weak var headerButton:UIButton!
    @IBOutlet weak var headerSecondLabel: UILabel!
    
    let distancePicker = UIPickerView()
    
    var data:[NaruMapApiManager.Document] = [] {
        didSet {
            DispatchQueue.main.async {[weak self]in
                self?.checkEmptyViewHidden()
            }
        }
    }
    
    weak var delegate:NaruMapSearchResultTableViewControllerDelegate? = nil
    var mapViewController:NaruMapViewController? {
        delegate as? NaruMapViewController
    }
    
    let disposeBag = DisposeBag()
    
    @objc func onSelect() {
        view.endEditing(true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        distancePicker.delegate = self
        distancePicker.dataSource = self
        headerTextField.inputView = distancePicker
        
        headerTextField.makeConfirmToolBar(title: "", buttonTitle: "완료", target: self, action: #selector(self.onSelect))
        emptyView.frame.size = tableView.frame.size
        emptyView.frame.size.height = 350
        emptyView.isHidden = true
        tableView.addSubview(emptyView)

        headerButton.rx.tap.bind { [unowned self](_) in
            headerTextField.becomeFirstResponder()
        }.disposed(by: disposeBag)
        
        if let range = mapViewController?.ranges {
            let index = UserDefaults.standard.getLastSelectedRangeIndex(rangeCount: range.count)
            headerTextField.text = range[index].title
            distancePicker.selectRow(index, inComponent: 0, animated: false)
        }
        if let img = mapViewController?.emptyViewImage {
            emptyImageView.image = img
        }
        
    }
    
    
    func checkEmptyViewHidden() {
        emptyView.isHidden = data.count > 0 || mapViewController?.isApiCall == false
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }

    // MARK: - Table view data source
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return data.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let data = self.data[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! NaruMapSearchResultTableViewCell
        cell.data = data
        
        return cell
    }
    

    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        delegate?.mapSearchResultSelect(data: data[indexPath.row],indexPath: indexPath)
//        let coordinate = data[indexPath.row].coordinate
        
//
//        if let ann = mapView?.annotations.filter({ (ann) -> Bool in
//            ann.coordinate.longitude == coordinate.longitude
//                && ann.coordinate.latitude == coordinate.latitude
//        }).first {
//            mapView?.selectAnnotation(ann, animated: true)
//            UIView.animateKeyframes(withDuration: 0.25, delay: 0.0, options: .calculationModeCubic) {[unowned self] in
//                mapView?.centerCoordinate = coordinate
//            } completion: {_ in
//
//            }
//        }
    }
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 65
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return headerView
    }
}




extension NaruMapSearchResultTableViewController : UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return mapViewController?.ranges.count ?? 0
    }
}

extension NaruMapSearchResultTableViewController : UIPickerViewDelegate {
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return mapViewController?.ranges[row].title
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if let vc = mapViewController {
            UserDefaults.standard.lastSelectedRangeIndex = row
            let title = vc.ranges[row].title
            vc.altitude = vc.ranges[row].range * 5
            headerTextField.text = title
            vc.reload()
            mapViewController?.mapView.camera.altitude = vc.ranges[row].range * 5
            if let location = LocationManager.shared.myLocation.last {
                UIView.animate(withDuration: 0.25, delay: 0, options: .curveEaseInOut) {[weak self]in
                    self?.mapViewController?.mapView.centerCoordinate = location.coordinate
                }
            }
        }
    }
}



class NaruMapSearchResultTableViewCell: UITableViewCell {
    @IBOutlet weak var typeLabel: UILabel!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var phoneCallButton: UIButton!
    
    var data:NaruMapApiManager.Document? = nil {
        didSet {
            updateUI()
        }
    }
    
    func updateUI() {
        phoneCallButton.setBackgroundImage(UIColor.black.circleImage(diameter: phoneCallButton.frame.size.width
        ), for: .normal)
        phoneCallButton.setBackgroundImage(UIColor.gray.circleImage(diameter: phoneCallButton.frame.size.width), for: .highlighted)
        typeLabel.text = data?.category_name
        nameLabel.text = data?.place_name
        addressLabel.text = data?.road_address_name
        phoneCallButton.isHidden = data?.phone.isEmpty == true
    }
    
    @IBAction func onTouchUpPhoneCallButton(_ sender: Any) {
        if let data = data {
            if let url = URL(string:"tel://\(data.phone)") {
                if UIApplication.shared.canOpenURL(url) {
                    UIApplication.shared.open(url, options: [:]) { (_) in
                        
                    }
                }
            }
        }
        
    }
    
    override func setHighlighted(_ highlighted: Bool, animated: Bool) {
        backgroundColor = highlighted ? #colorLiteral(red: 0.9607843137, green: 0.968627451, blue: 0.9803921569, alpha: 1) : .clear
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        backgroundColor = selected ? #colorLiteral(red: 0.9607843137, green: 0.968627451, blue: 0.9803921569, alpha: 1) : .clear
    }
}
