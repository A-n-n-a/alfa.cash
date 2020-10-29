//
//  WalletChartTableViewCell.swift
//  AlfaCash
//
//  Created by Anna Alimanova on 05.02.2020.
//  Copyright © 2020 Anna Alimanova. All rights reserved.
//

import UIKit
import Charts

class WalletChartTableViewCell: UITableViewCell, UIScrollViewDelegate, ChartViewDelegate {

    @IBOutlet weak var icon: UIImageView!
    @IBOutlet weak var titleLabel: TitleLabel!
    @IBOutlet weak var amountLabel: TitleLabel!
    @IBOutlet weak var moneyLabel: SubtitleLabel!
    @IBOutlet weak var labelsStack: UIStackView!
    @IBOutlet weak var chartContainer: UIView!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var chartView: LineChartView!
    
    var wallet: Wallet! {
        didSet {
            titleLabel.text = wallet.title
            amountLabel.text = "\(wallet.amount) \(wallet.currency.uppercased())"
            let currencyName = wallet.currency == "erc20" ? "eth" : wallet.currency
            let iconName = ThemeManager.currentTheme == .day ? currencyName : "\(currencyName)_dark"
            icon.image = UIImage(named: iconName)
            labelsStack.isHidden = false
            backgroundColor = ThemeManager.currentTheme.associatedObject.homePageToolBarColor
            chartContainer.backgroundColor = ThemeManager.currentTheme.associatedObject.homePageToolBarColor
            moneyLabel.text = wallet.money
            scrollView.delegate = self
            scrollView.alwaysBounceVertical = false
            setupChartView()
            setUpChart()
        }
    }
    
    func setUpChart() {
        var rates = [Rate]()
        switch wallet.coin {
        case .bitcoin:
            rates = WalletManager.btcRates
        case .bitcoinCash:
             rates = WalletManager.bchRates
        case .litecoin:
             rates = WalletManager.ltcRates
        case .ethereum:
             rates = WalletManager.ethRates
        case .xrp:
             rates = WalletManager.xrpRates
        case .stellar:
             rates = WalletManager.xlmRates
        case .tron:
             rates = WalletManager.trxRates
        case .eos:
             rates = WalletManager.eosRates
        default:
            break
        }
        
        if rates.isEmpty || ApplicationManager.ratesNeedUpdate {
            getRates()
        } else {
            setDataCount(rates: rates)
        }
    }
    
    func setupChartView() {
        chartView.delegate = self
        chartView.chartDescription?.enabled = false
        chartView.dragEnabled = true
        chartView.setScaleEnabled(false)
        chartView.pinchZoomEnabled = false
        chartView.xAxis.enabled = false
        chartView.legend.enabled = false
        chartView.rightAxis.enabled = false
        chartView.leftAxis.labelTextColor = ThemeManager.currentTheme.associatedObject.textColor
        chartView.leftAxis.removeAllLimitLines()
        chartView.noDataTextColor = ThemeManager.currentTheme.associatedObject.textColor
        chartView.noDataTextColor = ThemeManager.currentTheme.associatedObject.textColor
        chartView.animate(xAxisDuration: 1)
    }
    
    func setDataCount(rates: [Rate]) {
        guard let maxRate = rates.maxRate(), let minRate = rates.minRate() else { return }
        chartView.leftAxis.axisMaximum = Double(maxRate.price)
        chartView.leftAxis.axisMinimum = Double(minRate.price)
        
        var values: [ChartDataEntry] = []
        for rate in rates {
            let value = ChartDataEntry(x: Double(rate.timestamp), y: Double(rate.price))
            values.append(value)
        }
        
        let set1 = LineChartDataSet(entries: values, label: nil)
        set1.drawIconsEnabled = false
        set1.setColor(UIColor.kButtonColor.withAlphaComponent(0.9))
        set1.lineWidth = 3
        set1.drawCircleHoleEnabled = false
        set1.valueFont = .systemFont(ofSize: 0)
        set1.formLineWidth = 1
        set1.formSize = 15
        set1.drawCirclesEnabled = false
        set1.highlightEnabled = false
        set1.fillAlpha = 0.47
        
        set1.fill = Fill(CGColor: UIColor.kButtonColor.cgColor)
        set1.drawFilledEnabled = true
        
        let data = LineChartData(dataSet: set1)
        
        chartView.data = data
    }
    
    var cellActionButtonLabel: UILabel? {
        for subview in self.superview?.subviews ?? [] {
            if String(describing: subview).range(of: "UISwipeActionPullView") != nil {
                for view in subview.subviews {
                    if String(describing: view).range(of: "UISwipeActionStandardButton") != nil {
                        for sub in view.subviews {
                            if let label = sub as? UILabel {
                                return label
                            }
                        }
                    }
                }
            }
        }
        return nil
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        cellActionButtonLabel?.textColor = .black
    }
    
    func cellDidSwipe(_ swiped: Bool) {
        backgroundColor = swiped ? .kPinRowColor : .white
    }
    
    func setUpAddCoin() {
        titleLabel.text = "ADD_COIN".localized()
        labelsStack.isHidden = true
        icon.image = #imageLiteral(resourceName: "pin")
        backgroundColor = .white
    }
    
    func getRates() {
        NetworkManager.rates(walletId: wallet.id, period: .month) { [weak self] (rates, error) in
            DispatchQueue.main.async {
                if let rates = rates, !rates.isEmpty {
                    self?.setDataCount(rates: rates)
                    
                    switch self?.wallet.coin {
                    case .bitcoin:
                        WalletManager.btcRates = rates
                    case .bitcoinCash:
                         WalletManager.bchRates = rates
                    case .litecoin:
                         WalletManager.ltcRates = rates
                    case .ethereum:
                         WalletManager.ethRates = rates
                    case .xrp:
                         WalletManager.xrpRates = rates
                    case .stellar:
                         WalletManager.xlmRates = rates
                    case .tron:
                         WalletManager.trxRates = rates
                    case .eos:
                         WalletManager.eosRates = rates
                    default:
                        break
                    }
                }
            }
        }
    }
    
//    func addLineChart(rates: [Rate]) {
//
//        if !chartContainer.subviews.isEmpty {
//            for subview in chartContainer.subviews {
//                subview.removeFromSuperview()
//            }
//        }
//
//        let minXItemWidth: CGFloat = 20
//        let widthNeeded = CGFloat(rates.count) * minXItemWidth
//        let chartWidth = max(widthNeeded, UIScreen.main.bounds.width)
//
//        let lineChart = LineChart(frame: CGRect(x: 0, y: 0, width: chartWidth, height: chartContainer.bounds.height))
//        lineChart.area = false
//        lineChart.x.grid.count = CGFloat(rates.count)
//        lineChart.y.grid.count = 5
//        let points = rates.map({ $0.price })
//
//        lineChart.addLine(points, themed: true)
//
//        chartContainer.addSubview(lineChart)
//        lineChart.leadingAnchor.constraint(equalTo: chartContainer.leadingAnchor).isActive = true
//        lineChart.trailingAnchor.constraint(equalTo: chartContainer.trailingAnchor).isActive = true
//        lineChart.topAnchor.constraint(equalTo: chartContainer.topAnchor).isActive = true
//        lineChart.bottomAnchor.constraint(equalTo: chartContainer.bottomAnchor, constant: 2).isActive = true
//    }
}
