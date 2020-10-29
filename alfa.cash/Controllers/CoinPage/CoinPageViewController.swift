//
//  CoinPageViewController.swift
//  alfa.cash
//
//  Created by Anna Alimanova on 06.04.2020.
//  Copyright © 2020 Anna Alimanova. All rights reserved.
//

import UIKit
import Charts

class CoinPageViewController: BaseViewController, ChartViewDelegate {
    
    @IBOutlet weak var balanceLabel: UILabel!
    @IBOutlet weak var currencyLabel: UILabel!
    @IBOutlet weak var fiatLabel: ACLabel!
    
    @IBOutlet weak var transactionsView: UIView!
    @IBOutlet weak var myTransactionsLabel: ACLabel!
    @IBOutlet weak var triangleImage: UIImageView!
    @IBOutlet weak var transactionsViewHeight: NSLayoutConstraint!
    
    @IBOutlet weak var weekButtonWidth: NSLayoutConstraint!
    @IBOutlet weak var historyView: UIView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var tableViewHeight: NSLayoutConstraint!
    @IBOutlet weak var viewMoreButton: BorderedButton!
    
    @IBOutlet weak var priceLabel: UILabel!
    
    @IBOutlet weak var chartContainer: UIView!
    @IBOutlet weak var buttonsStack: UIStackView!
    @IBOutlet weak var hourButton: BorderedButton!
    
    @IBOutlet weak var toolBar: UIToolbar!
    @IBOutlet weak var sendLabel: ACLabel!
    @IBOutlet weak var exchangeLabel: ACLabel!
    @IBOutlet weak var receiveLabel: ACLabel!
    @IBOutlet weak var sendIcon: UIImageView!
    @IBOutlet weak var exchangeIcon: UIImageView!
    @IBOutlet weak var receiveIcon: UIImageView!
    
    @IBOutlet weak var chartView: LineChartView!
    
    var wallet: Wallet!
    var transactions = [ACTransaction]() {
        didSet {
            if transactions.isEmpty {
                transactionsView.isHidden = true
            } else {
                transactionsView.isHidden = false
                let height = CGFloat(min(transactions.count, 5)) * transactionCellHeight
                tableViewHeight.constant = height
                transactionsViewFullHeight = transactionsViewBaseHeight + height
            }
            tableView.reloadData()
        }
    }
    var isTransactionsShown = false {
        didSet {
            triangleImage.image = isTransactionsShown ? #imageLiteral(resourceName: "upTriangle") : #imageLiteral(resourceName: "triangleArrow")
        }
    }
    
    let transactionsViewShrinkedHeight: CGFloat = 0
    let transactionsViewBaseHeight: CGFloat = 72 //base height without tableView
    var transactionsViewFullHeight: CGFloat = 72
    let transactionCellHeight: CGFloat = 64

    override func viewDidLoad() {
        super.viewDidLoad()

        setUpTransactionsNavBar(title: "\(wallet.title) \(wallet.currency.uppercased())".localized())
        
        setUpBalanceView()
        setupChart()
        
        transactionsViewHeight.constant = transactionsViewShrinkedHeight
        tableView.register(cellClass: TransactionShortTableViewCell.self)
        
        getTransactions()
        getRates(period: .week)
        
        let size: CGSize = "W_WEEK".localized().size(withAttributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 14, weight: .medium)])
        weekButtonWidth.constant = size.width + 20
        view.layoutIfNeeded()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        navigationController?.setNavigationBarHidden(false, animated: false)
        setUpToolBar()
    }
    
    func setupChart() {
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

        let marker = BalloonMarker(color: UIColor.kHeaderColor,
                                   font: .systemFont(ofSize: 12),
                                   textColor: .white,
                                   insets: UIEdgeInsets(top: 8, left: 8, bottom: 20, right: 8))
        
        marker.chartView = chartView
        marker.minimumSize = CGSize(width: 80, height: 40)
        chartView.marker = marker
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
        set1.highlightColor = ThemeManager.currentTheme.associatedObject.textColor
        
        set1.highlightLineDashLengths = [5, 5]
        set1.fillAlpha = 0.47
        
        set1.fill = Fill(CGColor: UIColor.kButtonColor.cgColor)
        set1.drawFilledEnabled = true
        
        let data = LineChartData(dataSet: set1)
        
        chartView.data = data
    }
    
    func setUpToolBar() {
        view.bringSubviewToFront(toolBar)
        
        let toolBarColor = ThemeManager.currentTheme.associatedObject.homePageToolBarColor
        let view = UIView(frame: toolBar.frame)
        view.backgroundColor = toolBarColor
        let image = view.asImage()
        toolBar.setBackgroundImage(image, forToolbarPosition: .bottom, barMetrics: .default)
        
        let tintColor = ThemeManager.currentTheme.associatedObject.homePageToolBarTintColor
        let textColor = ThemeManager.currentTheme.associatedObject.homePageToolBarLabelTintColor
        
        sendLabel.textColor = textColor
        exchangeLabel.textColor = textColor
        receiveLabel.textColor = textColor
        sendLabel.setText("SEND")
        exchangeLabel.setText("EXCHANGE")
        receiveLabel.setText("RECEIVE")
        
        sendIcon.tintColor = tintColor
        exchangeIcon.tintColor = tintColor
        receiveIcon.tintColor = tintColor
    }
    
    func setUpBalanceView() {
        balanceLabel.text = wallet.amount
        currencyLabel.text = wallet.currency.uppercased()
        fiatLabel.text = wallet.money
        priceLabel.text = "\(FiatManager.currentFiat.sign)\(wallet.price ?? 0)"
    }
    
    func getTransactions() {
        NetworkManager.getTransactions(currency: wallet.currency, pageSize: 5) { [weak self] (transactions, error) in
            DispatchQueue.main.async {
                if let transactions = transactions {
                    self?.transactions = transactions
                }
            }
        }
    }
    
    func getRates(period: ChartPeriod) {
        NetworkManager.rates(walletId: wallet.id, period: period) { [weak self] (rates, error) in
            DispatchQueue.main.async {
                if let error = error {
                    self?.showError(error)
                }
                if let rates = rates, !rates.isEmpty {
//                    self?.addLineChart(rates: rates)
                    self?.setDataCount(rates: rates)
                    self?.chartContainer.isHidden = false
                    self?.buttonsStack.isHidden = false
                }
            }
        }
    }
    
    func addLineChart(rates: [Rate]) {
        
        if !chartContainer.subviews.isEmpty {
            for subview in chartContainer.subviews {
                subview.removeFromSuperview()
            }
        }
        
        let minXItemWidth: CGFloat = 20
        let widthNeeded = CGFloat(rates.count) * minXItemWidth
        let chartWidth = max(widthNeeded, UIScreen.main.bounds.width)
        
        let lineChart = LineChart(frame: CGRect(x: 0, y: 0, width: chartWidth, height: chartContainer.bounds.height))
        lineChart.area = false
        lineChart.x.grid.count = CGFloat(rates.count)
        lineChart.y.grid.count = 5
        let points = rates.map({ $0.price })
        
        lineChart.addLine(points, themed: true)
        
        chartContainer.addSubview(lineChart)
        lineChart.leadingAnchor.constraint(equalTo: chartContainer.leadingAnchor).isActive = true
        lineChart.trailingAnchor.constraint(equalTo: chartContainer.trailingAnchor).isActive = true
        lineChart.topAnchor.constraint(equalTo: chartContainer.topAnchor).isActive = true
        lineChart.bottomAnchor.constraint(equalTo: chartContainer.bottomAnchor).isActive = true
    }
    
    @IBAction func changePeriod(_ sender: BorderedButton) {
        for subview in buttonsStack.subviews {
            if let button = subview as? BorderedFilledButton {
                button.active = false
            }
            sender.active = true
        }
        
        let period = ChartPeriod.getPeriodForTag(sender.tag)
        getRates(period: period)
    }
    
    @IBAction func showTransactions(_ sender: Any) {
        isTransactionsShown.toggle()
        showTransactions(isTransactionsShown)
    }
    
    func showTransactions(_ show: Bool) {
        transactionsViewHeight.constant = show ? transactionsViewFullHeight : transactionsViewShrinkedHeight
        
        if !show {
            viewMoreButton.alpha = 0
        }
        UIView.animate(withDuration: 0.3, animations: {
            self.view.layoutIfNeeded()
        }) { (_) in
            if show {
                self.viewMoreButton.alpha = 1
            }
        }
        UIView.animate(withDuration: 0.3) {
            self.view.layoutIfNeeded()
        }
    }
    
    @IBAction func viewMoreInHistory(_ sender: Any) {
        
        NotificationCenter.default.post(name: Notification.Name.showHistory, object: nil, userInfo: ["wallet" : wallet as Any])
        navigationController?.popViewController(animated: true)
    }
    
    @IBAction func showSendScreen(_ sender: Any) {
           if let vc = UIStoryboard.get(flow: .sendFlow).get(controller: .send) as? SendViewController {
               vc.wallet = wallet
               navigationController?.pushViewController(vc, animated: true)
           }
       }
       
       @IBAction func showExchangeScreen(_ sender: Any) {
           if let vc = UIStoryboard.get(flow: .exchangeFlow).instantiateInitialViewController() as? ExchangeViewController {
                vc.walletFrom = wallet
                self.navigationController?.pushViewController(vc, animated: true)
           }
       }
       
       @IBAction func showReceiveScreen(_ sender: Any) {
           if let vc = UIStoryboard.get(flow: .receiveFlow).get(controller: .receive) as? ReceiveViewController {
               vc.wallet = wallet
               navigationController?.pushViewController(vc, animated: true)
           }
       }
}

extension CoinPageViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return min(transactions.count, 5)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellId(TransactionShortTableViewCell.self)) as! TransactionShortTableViewCell
        cell.transaction = transactions[indexPath.row]
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return transactionCellHeight
    }
}

public enum ChartPeriod: String {
    case hour = "hour"
    case day = "day"
    case week = "week"
    case month = "month"
    case year = "year"
    
    static func getPeriodForTag(_ tag: Int) -> ChartPeriod {
        switch tag {
        case 1:
            return .hour
        case 2:
            return .day
        case 3:
            return .week
        case 4:
            return .month
        default:
            return .year
        }
    }
}
