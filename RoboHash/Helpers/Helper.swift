//
//  Helper.swift
//  RoboHash
//
//  Created by Navin  Dev on 21/8/19.
//  Copyright © 2019 Navin  Dev. All rights reserved.
//

import UIKit


// Helper Singleton to avoid setting the format everytime

class SharedDateformatter {
    static let shared = SharedDateformatter()

    lazy var displayDateFormat: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale.current
        dateFormatter.dateStyle = .medium
        dateFormatter.timeStyle = .short
        return dateFormatter
    }()

    lazy var requestDateFormat: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "EEEE, dd LLL yyyy HH:mm:ss zzz"
        return dateFormatter
    }()
}


extension UIViewController {

    func showGenericError(title: String, handler: ((UIAlertAction) -> Void)? = nil) {
        showDefaultAlert(message: title, handler: handler)
    }

    func showDefaultAlert(message: String, handler: ((UIAlertAction) -> Void)? = nil) {
        let alert = UIAlertController(title: nil, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: handler))
        self.present(alert, animated: true)
    }
}

extension String {
    var containsWhitespace : Bool {
        return(self.rangeOfCharacter(from: .whitespacesAndNewlines) != nil)
    }
}


