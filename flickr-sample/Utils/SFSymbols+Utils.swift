//
//  SFSymbols+Utils.swift
//  flickr-sample
//
//  Created by Leo Quinteros on 12/12/23.
//

import UIKit
import SwiftUI

enum SFSymbol: String {
    case locationUnavailable = "location.slash.circle"
    case photosUnavailable = "exclamationmark.icloud"
}

extension Label where Title == Text, Icon == Image {
    init(_ titleKey: LocalizedStringKey, symbol: SFSymbol) {
        self.init(titleKey, systemImage: symbol.rawValue)
    }
}

extension UIImage {
    convenience init?(symbol: SFSymbol, withConfiguration symbolConfiguration: UIImage.SymbolConfiguration = .unspecified) {
        self.init(systemName: symbol.rawValue, withConfiguration: symbolConfiguration)
    }
}

