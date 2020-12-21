//
//  NaruMapSearchResultTableViewController.swift
//  NaruiMapKit
//
//  Created by Changyeol Seo on 2020/12/21.
//

import UIKit
import MapKit
import NaruiUIComponents

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
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        distancePicker.delegate = self
        distancePicker.dataSource = self
        headerTextField.inputView = distancePicker
        tableView.addSubview(emptyView)
        
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        emptyView.frame.size = tableView.frame.size
        emptyView.frame.size.height = 300
    }
    
    func checkEmptyViewHidden() {
        emptyView.isHidden = data.count > 0
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
        return (delegate as? NaruMapViewController)?.ranges.count ?? 0
    }
}

extension NaruMapSearchResultTableViewController : UIPickerViewDelegate {
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return (delegate as? NaruMapViewController)?.rangeTitles[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if let vc = (delegate as? NaruMapViewController) {
            let title = vc.rangeTitles[row]
            vc.altitude = CLLocationDistance(vc.ranges[row])
            headerTextField.text = title
            vc.reload()
            self.view.endEditing(true)
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
