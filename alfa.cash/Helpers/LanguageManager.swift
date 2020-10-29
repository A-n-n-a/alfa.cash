//
//  LanguageManager.swift
//  AlfaCash
//
//  Created by Anna Alimanova on 29.01.2020.
//  Copyright © 2020 Anna Alimanova. All rights reserved.
//

import Foundation
import RxLocalizer

class LanguageManager {
    
    static let sections: [Sections] = [.popular, .all]
    static let popularSection: [AppLanguage] = [.english, .russian, .arabic]
    static let allSection: [AppLanguage] = [.chinese, .spanish, .hindi, .portuguese, .japanese, .turkish, .french, .german, .italian]
    
    enum Sections {
        case popular
        case all
    }
    
    static var currentLanguage: AppLanguage {
        return ApplicationManager.profile?.language ?? .english
    }
    
    static func switchLanguage(language: AppLanguage? = nil) {
        Localizer.shared.changeLanguage.accept(language?.rawValue ?? currentLanguage.rawValue)
        Bundle.setLanguage(language?.rawValue ?? currentLanguage.rawValue)
    }
    
    enum Number: Int {
        case first = 1
        case second = 2
        
        var name: String {
            return String(describing: self)
        }
    }
    
    enum AppLanguage: String {
        case english = "en"
        case russian = "ru"
        case chinese = "zh"
        case spanish = "es"
        case hindi = "hi"
        case arabic = "ar"
        case portuguese = "pt"
        case japanese = "ja"
        case turkish = "tr"
        case french = "fr"
        case german = "de"
        case italian = "it"
        case otherLanguage = "other"
        
        var name: String {
            return String(describing: self)
        }
        
        static var thirdLanguage: AppLanguage {
            return (currentLanguage == .english || currentLanguage == .russian) ? .otherLanguage : currentLanguage
        }
        static var optionsCases: [AppLanguage] = [english, russian, thirdLanguage]
        
        static let allCases = [english, russian, .arabic, .chinese, .spanish, .hindi, .portuguese, .japanese, .turkish, .french, .german, .italian]
        
        var localizedName: String {
            switch self {
                
            case .arabic: return "عربى"
            case .chinese: return "中文"
            case .english: return "English"
            case .french: return "Français"
            case .german: return "Deutsch"
            case .hindi: return "हिन्दी"
            case .italian: return "Italiano"
            case .japanese: return "日本人"
            case .portuguese: return "Português"
            case .russian: return "Русский"
            case .spanish: return "Español"
            case .turkish: return "Türk"
            case .otherLanguage: return "OTHER_LANGUAGE".localized()
            }
        }
        
        var icon: UIImage? {
            return UIImage(named: self.rawValue)
        }
    }
}
