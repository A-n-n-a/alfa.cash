//
//  ThemeManager.swift
//  AlfaCash
//
//  Created by Anna Alimanova on 16.01.2020.
//  Copyright © 2020 Anna Alimanova. All rights reserved.
//

import UIKit
import RxTheme
import RxSwift

protocol Theme {
    
    var homePageBackgroundColor: UIColor { get }
    var homePageToolBarColor: UIColor { get }
    var homePageToolBarTintColor: UIColor { get }
    var homePageToolBarLabelTintColor: UIColor { get }
    
    var defaultBackgroundColor: UIColor { get }
    var cellBackgroundColor: UIColor { get }
    var cellSelectedBackgroundColor: UIColor { get }
    
    var navbarTextColor: UIColor { get }
    var headerTextColor: UIColor { get }
    var subtitleTextColor: UIColor { get }
    var textColor: UIColor { get }
    
    var buttonBackgroundColor: UIColor { get }
    var buttonTextColor: UIColor { get }
    
    var borderButtonBorderColor: UIColor { get }
    var borderButtonTextColor: UIColor { get }
    var borderButtonBackgroundColor: UIColor { get }
    
    var noBorderButtonTextColor: UIColor { get }
    var noBorderButtonBackgroundColor: UIColor { get }
    var noBorderThemedButtonTextColor: UIColor { get }
    
    var textfieldBackgroundColor: UIColor { get }
    var textFieldBorderColor: UIColor { get }
    var textFieldPlaceholderColor: UIColor { get }
    var textFieldTextColor: UIColor { get }
    
    //settings
    var backgroundSettingsColor: UIColor { get }
    var navbarTextSettingsColor: UIColor { get }
    var cellBackgroundSettingsColor: UIColor { get }
    var textSettingsColor: UIColor { get }
    
    var homePageButtonSelectedColor: UIColor { get }
    var homePageButtonDeselectedColor: UIColor { get }
    
    var qrBackgroundColor: UIColor { get }
    var tagBackgroundColor: UIColor { get }
    var tagLabelColor: UIColor { get }
    
    var borderFilledButtonBackgroundColor: UIColor { get }
    var borderFilledButtonTextColor: UIColor { get }
    
    var separatorColor: UIColor { get }
    var blueLabelColor: UIColor { get }
    var menuBackground: UIColor { get }
}

class ThemeManager {
    
    static let shared = ThemeManager()
    private init() {}
    
    func saveTheme(_ theme: ThemeType) {
        UserDefaults.standard.set(theme.rawValue, forKey: Constants.Main.udColorTheme)
    }
    
    static var currentTheme: ThemeType {
        if let themeName = UserDefaults.standard.string(forKey: Constants.Main.udColorTheme) {
            return ThemeType(rawValue: themeName) ?? .day
        }
        return .day
    }
    
    static var availableThemes: [ThemeType] = [.day, .night, .trueNight]

    struct DayTheme: Theme {
        
        let homePageBackgroundColor = UIColor.kDefaultBackgroundNight
        let homePageToolBarColor = UIColor.kWhiteColor
        let homePageToolBarTintColor = UIColor.kDefaultBackgroundNight
        let homePageToolBarLabelTintColor = UIColor.kDefaultBackgroundNight
        
        let defaultBackgroundColor = UIColor.kWhiteColor
        
        let cellBackgroundColor = UIColor.kCellBackgroundDay
        let cellSelectedBackgroundColor = UIColor.kCellBackgroundDay
        
        let navbarTextColor = UIColor.kNavBarTextColor
        let headerTextColor = UIColor.kHeaderColor
        let subtitleTextColor = UIColor.kHeaderColor
        let textColor = UIColor.kTextColor
        
        let buttonBackgroundColor =  UIColor.kButtonColor
        let buttonTextColor = UIColor.kWhiteColor
        
        let borderButtonBorderColor = UIColor.kButtonColor
        let borderButtonTextColor = UIColor.kButtonColor
        let borderButtonBackgroundColor = UIColor.clear
        
        let noBorderButtonTextColor = UIColor.kNavBarTextColor
        let noBorderButtonBackgroundColor = UIColor.kNoBorderBackgroundColor
        let noBorderThemedButtonTextColor = UIColor.kNavBarTextColor
        
        let textfieldBackgroundColor = UIColor.kCellBackgroundDay
        let textFieldBorderColor = UIColor.kTextFieldBorderDay
        let textFieldPlaceholderColor = UIColor.kPlaceholderColor
        let textFieldTextColor = UIColor.kDefaultBackgroundTrueNight
        
        //settings
        let backgroundSettingsColor = UIColor.kWhiteColor
        let navbarTextSettingsColor = UIColor.kBlackColor
        let cellBackgroundSettingsColor = UIColor.kCellBackgroundDay
        let textSettingsColor = UIColor.kTextColor
        
        let homePageButtonSelectedColor = UIColor.kWhiteColor
        let homePageButtonDeselectedColor = UIColor.kNoBorderButtonTextColor
        
        let qrBackgroundColor = UIColor.kCellBackgroundDay
        let tagBackgroundColor = UIColor.kTagColor
        let tagLabelColor = UIColor.kTagTextColor
        
        let borderFilledButtonBackgroundColor = UIColor.white
        let borderFilledButtonTextColor = UIColor.kButtonColor
        let separatorColor = UIColor.kTextFieldBorderDay
        let blueLabelColor = UIColor.kDefaultBackgroundNight
        let menuBackground = UIColor.kQRBackgroundNight
    }

    struct NightTheme: Theme {
        
        let homePageBackgroundColor = UIColor.kDefaultBackgroundNight
        let homePageToolBarColor = UIColor.kCellBackgroundNight
        let homePageToolBarTintColor = UIColor.kButtonColor
        let homePageToolBarLabelTintColor = UIColor.white
        
        let defaultBackgroundColor = UIColor.kDefaultBackgroundNight
        
        let cellBackgroundColor = UIColor.kCellBackgroundNight
        let cellSelectedBackgroundColor = UIColor.white.withAlphaComponent(0.1)
        
        let navbarTextColor = UIColor.kWhiteColor
        let headerTextColor = UIColor.kWhiteOpaqueColor
        let subtitleTextColor = UIColor.kWhiteOpaqueColor
        let textColor = UIColor.kWhiteColor
        
        let buttonBackgroundColor =  UIColor.kButtonColor
        let buttonTextColor = UIColor.kWhiteColor
        
        let borderButtonBorderColor = UIColor.kButtonColor
        let borderButtonTextColor = UIColor.kButtonColor
        let borderButtonBackgroundColor = UIColor.clear //?
        
        let noBorderButtonTextColor = UIColor.kNoBorderButtonTextColor
        let noBorderButtonBackgroundColor = UIColor.kNoBorderBackgroundColor
        let noBorderThemedButtonTextColor = UIColor.kWhiteOpaqueColor
        
        let textfieldBackgroundColor = UIColor.kCellBackgroundNight
        let textFieldBorderColor = UIColor.kCellBackgroundNight
        let textFieldPlaceholderColor = UIColor.kWhiteColor
        let textFieldTextColor = UIColor.kWhiteColor
        
        //settings
        let backgroundSettingsColor = UIColor.kWhiteColor
        let navbarTextSettingsColor = UIColor.kBlackColor
        let cellBackgroundSettingsColor = UIColor.kCellBackgroundDay
        let textSettingsColor = UIColor.kTextColor
        
        let homePageButtonSelectedColor = UIColor.kWhiteColor
        let homePageButtonDeselectedColor = UIColor.kButtonColor
        
        let qrBackgroundColor = UIColor.kQRBackgroundNight
        let tagBackgroundColor = UIColor.kButtonColor
        let tagLabelColor = UIColor.white
        
        let borderFilledButtonBackgroundColor = UIColor.kButtonColor
        let borderFilledButtonTextColor = UIColor.white
        
        let separatorColor = UIColor.kWhiteOpaqueColor
        let blueLabelColor = UIColor.kWhiteColor
        let menuBackground = UIColor.kQRBackgroundNight
    }
    
    struct TrueNightTheme: Theme {
        
        let homePageBackgroundColor = UIColor.kDefaultBackgroundTrueNight
        let homePageToolBarColor = UIColor.kCellBackgroundTrueNight
        let homePageToolBarTintColor = UIColor.kButtonColor
        let homePageToolBarLabelTintColor = UIColor.kButtonColor
        
        let defaultBackgroundColor = UIColor.kDefaultBackgroundTrueNight
        
        let cellBackgroundColor = UIColor.kCellBackgroundTrueNight
        let cellSelectedBackgroundColor = UIColor.white.withAlphaComponent(0.1)
        
        let navbarTextColor = UIColor.kWhiteColor
        let headerTextColor = UIColor.kWhiteOpaqueColor
        let subtitleTextColor = UIColor.kWhiteOpaqueColor
        let textColor = UIColor.kWhiteColor
        
        let buttonBackgroundColor =  UIColor.kButtonColor
        let buttonTextColor = UIColor.kWhiteColor
        
        let borderButtonBorderColor = UIColor.kButtonColor //?
        let borderButtonTextColor = UIColor.kButtonColor
        let borderButtonBackgroundColor = UIColor.clear //?
        
        let noBorderButtonTextColor = UIColor.kNoBorderButtonTextColor
        let noBorderButtonBackgroundColor = UIColor.kNoBorderBackgroundColor
        let noBorderThemedButtonTextColor = UIColor.kWhiteOpaqueColor
        
        let textfieldBackgroundColor = UIColor.kTextFieldBackgroundTrueNight
        let textFieldBorderColor = UIColor.kTextFieldBackgroundTrueNight
        let textFieldPlaceholderColor = UIColor.kWhiteColor
        let textFieldTextColor = UIColor.kWhiteColor
        
        //settings
        let backgroundSettingsColor = UIColor.kWhiteColor
        let navbarTextSettingsColor = UIColor.kBlackColor
        let cellBackgroundSettingsColor = UIColor.kCellBackgroundDay
        let textSettingsColor = UIColor.kTextColor
        
        let homePageButtonSelectedColor = UIColor.kBlackColor
        let homePageButtonDeselectedColor = UIColor.kButtonColor
        
        let qrBackgroundColor = UIColor.kQRBackgroundTrueNight
        let tagBackgroundColor = UIColor.kButtonColor
        let tagLabelColor = UIColor.kBlackColor
        
        let borderFilledButtonBackgroundColor = UIColor.kButtonColor
        let borderFilledButtonTextColor = UIColor.white
        
        let separatorColor = UIColor.kWhiteOpaqueColor
        let blueLabelColor = UIColor.kWhiteColor
        let menuBackground = UIColor.kMenuBackgroundTrueNight
    }

    enum ThemeType: String, ThemeProvider {
        
        case day = "day"
        case night
        case trueNight
        
        var associatedObject: Theme {
            switch self {
            
            case .day: return DayTheme()
            case .night: return NightTheme()
            case .trueNight: return TrueNightTheme()
            }
        }
        
        var name: String {
            switch self {
            case .day :
                return "DAY_MODE"
            case .night:
                return "NIGHT_MODE"
            case .trueNight:
                return "TRUE_DARK_MODE"
            }
        }
    }

    let themeService = ThemeType.service(initial: ThemeManager.currentTheme)
    func themed<T>(_ mapper: @escaping ((Theme) -> T)) -> Observable<T> {
        return themeService.attrStream(mapper)
    }
}
