//
//  ChartViewController.swift
//  CovidSearch
//
//  Created by 木下健一 on 2021/12/11.
//

import UIKit
import Charts

class ChartViewController: UIViewController {
    
    let colors = Colors()
    var prefecture = UILabel()
    var pcr = UILabel()
    var pcrCount = UILabel()
    var cases = UILabel()
    var casesCount = UILabel()
    var deaths = UILabel()
    var deathsCount = UILabel()
    var array:[CovidInfo.Prefecture] = []
    var chartView:HorizontalBarChartView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        let gradientLayer = CAGradientLayer()
        gradientLayer.frame = CGRect(x: 0, y: 0, width: view.frame.size.width, height: 60)
        gradientLayer.colors = [colors.bluePurple.cgColor, colors.blue.cgColor,]
        gradientLayer.startPoint = CGPoint.init(x: 0, y: 0)
        gradientLayer.endPoint = CGPoint.init(x: 1, y: 1)
        view.layer.insertSublayer(gradientLayer, at: 0)
        
        let backButton = UIButton(type: .system)
        backButton.frame = CGRect(x: 10, y: 30, width: 20, height: 20)
        backButton.setImage(UIImage(named: "back"), for: .normal)
        backButton.tintColor = colors.white
        backButton.titleLabel?.font = .systemFont(ofSize: 20)
        backButton.addTarget(self, action: #selector(backButtonAction), for: .touchUpInside)
        view.addSubview(backButton)
        
        let nextButton = UIButton(type: .system)
        nextButton.frame = CGRect(x: view.frame.size.width - 105, y: 25, width: 100, height: 30)
        nextButton.setTitle("円グラフ", for: .normal)
        nextButton.setTitleColor(colors.white, for: .normal)
        nextButton.titleLabel?.font = .systemFont(ofSize: 20)
        nextButton.addTarget(self, action: #selector(goCircle), for: .touchUpInside)
        view.addSubview(nextButton)
        
        let segment = UISegmentedControl(items: ["感染者数", "PCR数", "死者数"])
        segment.frame = CGRect(x: 10, y: 70, width: view.frame.size.width - 20, height: 20)
        segment.selectedSegmentTintColor = colors.blue
        segment.selectedSegmentIndex = 0
        segment.setTitleTextAttributes([NSAttributedString.Key.foregroundColor: UIColor.white], for: .selected)
        segment.setTitleTextAttributes([NSAttributedString.Key.foregroundColor: colors.bluePurple], for: .normal)
        segment.addTarget(self, action: #selector(switchAction), for: .valueChanged)
        view.addSubview(segment)
        
        let searchBar = UISearchBar()
        searchBar.frame = CGRect(x: 10, y: 100, width: view.frame.size.width - 20, height: 20)
        searchBar.delegate = self
        searchBar.placeholder = "都道府県を漢字で入力"
        searchBar.showsCancelButton = true
        searchBar.tintColor = colors.blue
        view.addSubview(searchBar)
        
        let uiView = UIView()
        uiView.frame = CGRect(x: 10, y: 480, width: view.frame.size.width - 20, height: 167)
        uiView.layer.cornerRadius = 10
        uiView.backgroundColor = .white
        uiView.layer.shadowColor = colors.black.cgColor
        uiView.layer.shadowOffset = CGSize(width: 0, height: 2 )
        uiView.layer.shadowOpacity = 0.4
        uiView.layer.shadowRadius = 10
        view.addSubview(uiView)
        
        
        bottomLabel(uiView, prefecture,1, 10, text: "東京", size: 30, weight: .ultraLight, color: colors.black)
        bottomLabel(uiView, pcr, 0.39, 50, text: "PCR数", size: 15, weight: .bold, color: colors.bluePurple)
        bottomLabel(uiView, pcrCount, 0.39, 85, text: "", size: 50, weight: .bold, color: colors.blue)
        bottomLabel(uiView, cases, 1, 50, text: "感染者数", size: 15, weight: .bold, color: colors.bluePurple)
        bottomLabel(uiView, casesCount, 1, 85, text: "22222", size: 30, weight: .bold, color: colors.blue)
        bottomLabel(uiView, deaths, 1.61, 50, text: "死者数", size: 15, weight: .bold, color: colors.bluePurple)
        bottomLabel(uiView, deathsCount, 1.61, 85, text: "2222", size: 30, weight: .bold, color: colors.blue)
        

        view.backgroundColor = .systemGroupedBackground
        
        
        for i in 0..<CovidSinglton.shared.prefecture.count {
            if CovidSinglton.shared.prefecture[i].name_ja == "東京" {
                prefecture.text = CovidSinglton.shared.prefecture[i].name_ja
                pcrCount.text = "\(CovidSinglton.shared.prefecture[i].pcr)"
                casesCount.text = "\(CovidSinglton.shared.prefecture[i].cases)"
                deathsCount.text = "\(CovidSinglton.shared.prefecture[i].deaths)"
            }
        }
        
        chartView = HorizontalBarChartView(frame: CGRect(x: 0, y: 150, width: view.frame.size.width, height: 300))
        chartView.animate(yAxisDuration: 1.0, easingOption: .easeOutCirc)
        chartView.xAxis.labelCount = 10
        chartView.xAxis.labelTextColor = colors.bluePurple
        chartView.doubleTapToZoomEnabled = false
        chartView.delegate = self
        chartView.pinchZoomEnabled = false
        chartView.leftAxis.labelTextColor = colors.bluePurple
        chartView.xAxis.drawGridLinesEnabled = false
        chartView.legend.enabled = false
        chartView.rightAxis.enabled = false
        
        array = CovidSinglton.shared.prefecture
        dataSet()
    }
    func dataSet() {
        var names:[String] = []
        for i in 0...9 {
            names += ["\(self.array[i].name_ja)"]
        }
        chartView.xAxis.valueFormatter = IndexAxisValueFormatter(values: names)
        
        var entries:[BarChartDataEntry] = []
        for i in 0...9 {
            entries += [BarChartDataEntry(x: Double(i), y: Double(array[i].cases))]
        }
            let set = BarChartDataSet(entries: entries, label: "県別状況")
            set.colors = [colors.blue]
            set.valueTextColor = colors.bluePurple
            set.highlightColor = colors.white
            chartView.data = BarChartData(dataSet: set)
            view.addSubview(chartView)
    }
    
    @objc func switchAction(sender: UISegmentedControl) {
        switch sender.selectedSegmentIndex {
        case 0:
            print("感染者数")
        case 1:
            print("PCR数")
        case 2:
            print("死者数")
        default:
            break
        }
    }
    @objc func backButtonAction() {
        dismiss(animated: true, completion: nil)
    }
    @objc func goCircle() {
        print("tappedNextButton")
    }
    func bottomLabel(_ parentView: UIView, _ label: UILabel, _ x: CGFloat, _ y: CGFloat, text: String, size: CGFloat, weight: UIFont.Weight, color: UIColor) {

        label.text = text
        label.textColor = color
        label.textAlignment = .center
        label.adjustsFontSizeToFitWidth = true
        label.font = .systemFont(ofSize: size, weight: weight)
        label.frame = CGRect(x: 0, y: y, width: parentView.frame.size.width / 3.5, height: 50)
        label.center.x = view.center.x * x - 10
        parentView.addSubview(label)
    }
}
//MARK: UISearchBarDelegate
extension ChartViewController: UISearchBarDelegate {
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        print("検索ボタンがタップ")
    }
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        print("キャンセルボタンがタップ")
    }
}
//MARK: ChartViewDelegate
extension ChartViewController: ChartViewDelegate {
    
}
