//
//  CitiesForecastViewController.swift
//  ADWeatherApp
//
//  Created by VIPadm on 24/04/21.
//

import UIKit

class CitiesForecastViewController: UIViewController {
    var finalRecordsArr = [[String: Any]]()
    var locality: String = ""
    var country: String = ""
    @IBOutlet weak var localityLbl: UILabel!
    
    @IBOutlet weak var titleLbl: UILabel!
    
    let todayDate: NSDate =  NSDate()
    
    @IBOutlet weak var dates_CV: UICollectionView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        self.navigationController?.navigationBar.isHidden = true
        
        dates_CV.backgroundColor = UIColor.clear
        dates_CV.register(UINib(nibName: "DayCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "DayCollectionViewCell")
        
        
    }
    @IBAction func HomeButtonAction(sender: UIButton){
        self.navigationController?.popViewController(animated: true)
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        
        localityLbl.text = locality + ", " + country
        
        let isMetricType = UserDefaults.standard.bool(forKey: "IsMetricTypeKey")
        
        var unitType = ""
        if isMetricType {
            unitType = "metric"
        }else{
            unitType = "imperial"
        }
        titleLbl.text = "FORECAST - \( unitType.uppercased())"
        
        let url = WeatherAPI.ForecastApi + "?q=\(locality)" + "&appid=\(apiKey)" + "&units=\(unitType)"
        let urlString = url.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
        
        APIRequestClass.shared.APIRequestWithWeatherUrl(url: urlString!) { result in
            
            switch result{
            case .success(let data):
                
                do {
                    guard let forecastData = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as? [String: Any] else { return }
                    DispatchQueue.main.async { [self] in
                        print(forecastData)
                        
                        OrderDateWise(resultData: forecastData)
                        
                    }
                }
                catch let err {
                    print(err.localizedDescription)
                }
                
                break
            case .failure(let err):
                print(err.localizedDescription)
                break
            }
        }
        
    }
    
    func OrderDateWise(resultData: [String : Any]) {
        
        guard let resultRecordsArr = resultData["list"] as? [[String: Any]]
        else{
            let alert = UIAlertController(title:locality, message: "City forecast not found.\nPlease refere open weather api...", preferredStyle: UIAlertController.Style.alert)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: { _ in
                self.navigationController?.popViewController(animated: true)
            }))
            self.present(alert, animated: true, completion: nil)
            return
            
        }
        
        
        for dict in resultRecordsArr {
            
            guard let dateStr = dict["dt_txt"] as? String else { return }
            dateformater.dateFormat = "yyyy-MM-dd HH:mm:ss"
            let date = dateformater.date(from: dateStr)!
            dateformater.dateFormat = "dd/MM"
            let tempDate = dateformater.string(from: date)
            var tempArr = [[String: Any]]()
            
            if finalRecordsArr.contains(where: { $0["name"] as? String == tempDate }) {
                
                var filteredData = finalRecordsArr.filter { $0["name"] as? String == tempDate }[0]
                tempArr.append(contentsOf: filteredData[tempDate] as! [[String: Any]])
                tempArr.append(dict)
                filteredData[tempDate] = tempArr
            }
            else {
                
                tempArr.append(dict)
                let dict1 = ["name": tempDate, tempDate: tempArr] as [String : Any]
                finalRecordsArr.append(dict1)
            }
        }
        
        print(finalRecordsArr)
        
        
        dates_CV.reloadData()
    }
    
}

extension CitiesForecastViewController: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        return finalRecordsArr.count
        
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize
    {
        return CGSize(width: collectionView.frame.size.width-26, height:110)
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "DayCollectionViewCell", for: indexPath) as! DayCollectionViewCell
        cell.cellBV.layer.cornerRadius = 6.0
        cell.cellBV.layer.borderWidth = 1.0
        cell.cellBV.layer.borderColor = UIColor.gray.cgColor
        
        cell.cellBV.backgroundColor = getColour(row: indexPath.row)
        
        let rec = finalRecordsArr[indexPath.row]
        
        let todaysdate = Date.getCurrentDate()
        let dateStr = rec["name"] as? String
        if dateStr ==  todaysdate{
            cell.dateLbl.text = "Today"
        }else{
            cell.dateLbl.text = rec["name"] as? String
        }
        
        
        let tempDic = (rec[rec["name"] as! String] as! [[String: Any]])[0]
        let feelType = (tempDic["weather"] as! [[String: Any]])[0]["description"] as? String
        cell.feelLbl.text = feelType
        
        let humidityValue = String(format: "%.1f", (((tempDic["main"] as! [String: Any])["humidity"])) as! Double)
        cell.humidityLbl.text = "Humidity: \(humidityValue)"
        
        //String(format: "%.1f C", (((dictToday["main"] as! [String: Any])["humidity"])))
        
        let tempMax = String(format: "%.1f", (((tempDic["main"] as! [String: Any])["temp_max"] as! Double)))
        let tempMin = String(format: "%.1f", (((tempDic["main"] as! [String: Any])["temp_min"] as! Double)))
        cell.tempLbl.text = "\(tempMax)°" + "/" + "\(tempMin)°"
        
        let iconID = String(((tempDic["weather"] as! [[String: Any]])[0]["icon"] as? String)!)
        let feelTypeUrl = "http://openweathermap.org/img/wn/\(iconID)@2x.png"
        
        if let imageUrl = URL(string: feelTypeUrl){
            
            UIImage.loadFrom(url: imageUrl) { image in
                cell.cloudTypeImgView.image = image
            }
        }
        
        let windSpeed = String(format: "Wind: %.1f phr", (((tempDic["wind"] as! [String: Any])["speed"] as! Double)))
        cell.rainChancesLbl.text = windSpeed
        return cell
    }
    
    
    
    func getColour(row: Int) -> UIColor{
        
        switch row {
        case 0:
            return UIColor.init(red: 153.0/255, green: 153.0/255, blue: 255.0/255, alpha: 1.0)
        case 1:
            return UIColor.init(red: 204.0/255, green: 255.0/255, blue: 204.0/255, alpha: 1.0)
        case 2:
            return UIColor.init(red: 204.0/255, green: 255.0/255, blue: 153.0/255, alpha: 1.0)
        case 3:
            return UIColor.init(red: 255.0/255, green: 153.0/255, blue: 204.0/255, alpha: 1.0)
        case 4:
            return UIColor.init(red: 204.0/255, green: 255.0/255, blue: 255.0/255, alpha: 1.0)
        case 5:
            return UIColor.init(red: 255.0/255, green: 255.0/255, blue: 153.0/255, alpha: 1.0)
            
        default:
            return UIColor.init(red: 229.0/255, green: 204.0/255, blue: 255.0/255, alpha: 1.0)
        }
        
    }
    
    
    
}
extension UIImage {
    
    public static func loadFrom(url: URL, completion: @escaping (_ image: UIImage?) -> ()) {
        DispatchQueue.global().async {
            if let data = try? Data(contentsOf: url) {
                DispatchQueue.main.async {
                    completion(UIImage(data: data))
                }
            } else {
                DispatchQueue.main.async {
                    completion(nil)
                }
            }
        }
    }
    
}

extension Date {
    
    static func getCurrentDate() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd/MM"
        return dateFormatter.string(from: Date())
        
    }
}
