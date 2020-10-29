//
//  FiltersView.swift
//  alfa.cash
//
//  Created by Anna Alimanova on 18.02.2020.
//  Copyright © 2020 Anna Alimanova. All rights reserved.
//

import UIKit

protocol FiltersViewDelegate {
    func filtersSelected(_ filters: [Filter])
    func hideFilters()
}

class FiltersView: UIView {
    
    @IBOutlet weak var titleLabel: ACLabel!
    @IBOutlet weak var subtitleLabel: ACLabel!
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var resetTitle: SubtitleLabel!
    
    var timeFilters: [Filter] = [Filter(type: .time, subType: .week, selected: false),
                                 Filter(type: .time, subType: .month, selected: false),
                                 Filter(type: .time, subType: .year, selected: false)]
    var typeFilters: [Filter] = [Filter(type: .type, subType: .send, selected: false),
                                 Filter(type: .type, subType: .receive, selected: false),
                                 Filter(type: .type, subType: .exchange, selected: false)]
    var coinFilters: [Filter] = [] {
        didSet {
            tableView.reloadData()
        }
    }
    
    var selectedFilters = [Filter]()
    var selectedFiltersCopy = [Filter]() {
        didSet {
            updateResetColor()
        }
    }
    var delegate: FiltersViewDelegate?
    
    var defaultResetColor: UIColor {
        return ThemeManager.currentTheme == .day ? UIColor.darkGray : UIColor.white.withAlphaComponent(0.5)
    }
   
    override init(frame: CGRect) {
       super.init(frame: frame)
       
       setup()
    }
   
    required init?(coder aDecoder: NSCoder) {
       super.init(coder: aDecoder)
       
       setup()
    }
   
    private func setup() {
        let nib =  UINib(nibName: "FiltersView", bundle: Bundle(for: type(of: self)))
        let view = nib.instantiate(withOwner: self, options: nil)[0] as! UIView
        view.frame = self.bounds
        view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.frame = CGRect(origin: CGPoint.zero, size: self.frame.size)
        self.addSubview(view)
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(cellClass: FiltersTableViewCell.self)
        
        NotificationCenter.default.addObserver(self, selector: #selector(updateWallets), name: NSNotification.Name.walletsUpdate, object: nil)
        
        let swipe = UISwipeGestureRecognizer(target: self, action: #selector(swipeAction))
        swipe.direction = .down
        self.addGestureRecognizer(swipe)
        
        resetTitle.textColor = defaultResetColor
    }
    
    @objc func swipeAction() {
        delegate?.hideFilters()
    }
    
    @objc func updateWallets() {
        coinFilters = WalletManager.pinnedWallets.map({ (wallet) -> Filter in
            return Filter(type: .coin, subType: .coin, currency: wallet.currency, selected: false)
        })
    }
    
    func updateResetColor() {
        resetTitle.textColor = selectedFiltersCopy.isEmpty ? defaultResetColor : UIColor.kButtonColor
    }
    
    func resetTimeFilter() {
        timeFilters = timeFilters.map { (filter) -> Filter in
            return Filter(type: filter.type, subType: filter.subType, currency: filter.currency, selected: false)
        }
    }
    func resetTypeFilter() {
        typeFilters = typeFilters.map { (filter) -> Filter in
            return Filter(type: filter.type, subType: filter.subType, currency: filter.currency, selected: false)
        }
    }
    func resetCoinFilter() {
        coinFilters = coinFilters.map { (filter) -> Filter in
            return Filter(type: filter.type, subType: filter.subType, currency: filter.currency, selected: false)
        }
    }
    
    func numberOfFiltersRows(filters: [String]) -> CGFloat {
        
        let innerPadding: CGFloat = UIDevice.current.iPhoneSE() ? 10 : 30
        let padding: CGFloat = 10
        var prevWidth: CGFloat = 0
        var rows: CGFloat = 1
        for filter in filters {
            let width = filter.size(withAttributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 14, weight: .medium)]).width + innerPadding
            if (prevWidth + padding + width) > (UIScreen.main.bounds.width - innerPadding * 2) {
                rows += 1
                prevWidth = width
            } else {
                prevWidth += width
            }
        }
        return rows
    }
    
    func clearSelectedFilters(type: FiltersType) {
        for (index, filter) in selectedFiltersCopy.enumerated() {
            if filter.type == type {
                selectedFiltersCopy.remove(at: index)
            }
        }
    }
    
    @IBAction func resetFilters(_ sender: Any) {
        selectedFiltersCopy = []
        selectedFilters = []
        resetTimeFilter()
        resetTypeFilter()
        resetCoinFilter()
        tableView.reloadData()
        resetTitle.textColor = defaultResetColor
        delegate?.filtersSelected([])
    }
    
    @IBAction func applyFilters(_ sender: Any) {
        if selectedFilters != selectedFiltersCopy {
            selectedFilters = selectedFiltersCopy
            delegate?.filtersSelected(selectedFilters)
        } else {
            delegate?.filtersSelected(selectedFilters)
        }
    }
    
}

extension FiltersView: UITableViewDataSource, UITableViewDelegate {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 3
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: FiltersTableViewCell.self)) as! FiltersTableViewCell
        cell.delegate = self
        cell.section = indexPath.section
        switch indexPath.section {
        case 0:
            cell.filters = timeFilters
        case 1:
            cell.filters = typeFilters
        default:
            cell.filters = coinFilters
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        switch section {
        case 0:
            return "BY_DATE".headerThemedViewWithTitle()
        case 1:
            return "BY_OPERATION".headerThemedViewWithTitle()
        default:
            return "BY_CURRENCY".headerThemedViewWithTitle()
        }
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 35
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        switch indexPath.section {
        case 0:
            let filters = timeFilters.compactMap({ return $0.subType.name })
            let numberOfRows = numberOfFiltersRows(filters: filters)
            return numberOfRows * 40 + (numberOfRows - 1) * 10
        case 1:
            let filters = typeFilters.compactMap({ return $0.subType.name })
            let numberOfRows = numberOfFiltersRows(filters: filters)
            return numberOfRows * 40 + (numberOfRows - 1) * 10
        default:
            let filters = coinFilters.compactMap({ return $0.currency?.uppercased() })
            let numberOfRows = numberOfFiltersRows(filters: filters)
            return numberOfRows * 40 + (numberOfRows - 1) * 10
        }
    }
}

extension FiltersView: FiltersTableViewCellDelegate {
    func filterSelected(at indexPath: IndexPath) {
        switch indexPath.section {
        case 0:
            if timeFilters[indexPath.item].selected {
                timeFilters[indexPath.item].selected = false
                clearSelectedFilters(type: .time)
            } else {
                resetTimeFilter()
                timeFilters[indexPath.item].selected = true
                clearSelectedFilters(type: .time)
                selectedFiltersCopy.append(timeFilters[indexPath.item])
            }
        case 1:
            if typeFilters[indexPath.item].selected {
                typeFilters[indexPath.item].selected = false
                clearSelectedFilters(type: .type)
            } else {
                resetTypeFilter()
                typeFilters[indexPath.item].selected = true
                clearSelectedFilters(type: .type)
                selectedFiltersCopy.append(typeFilters[indexPath.item])
            }
        default:
            if coinFilters[indexPath.item].selected {
                coinFilters[indexPath.item].selected = false
                clearSelectedFilters(type: .coin)
            } else {
                resetCoinFilter()
                coinFilters[indexPath.item].selected = true
                clearSelectedFilters(type: .coin)
                selectedFiltersCopy.append(coinFilters[indexPath.item])
            }
        }
        tableView.reloadData()
    }
}

enum FiltersType {
    case time
    case type
    case coin
}

enum FiltersSubtype {
    case week
    case month
    case year
    case send
    case receive
    case exchange
    case coin
    
    var localizedKey: String {
        switch self {
        case .week: return "LAST_WEEK"
        case .month: return "LAST_MONTH"
        case .year: return "LAST_YEAR"
        case .send: return "SENT"
        case .receive: return "RECEIVED"
        case .exchange: return "EXCHANGED"
        case .coin: return ""
        }
    }
    var name: String {
        switch self {
        case .week: return "LAST_WEEK".localized()
        case .month: return "LAST_MONTH".localized()
        case .year: return "LAST_YEAR".localized()
        case .send: return "SENT".localized()
        case .receive: return "RECEIVED".localized()
        case .exchange: return "EXCHANGED".localized()
        case .coin: return ""
        }
    }
}
