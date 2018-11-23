//
//  Action.swift
//  WolmoReactiveCore
//
//  Created by Diego Quiros on 22/11/2018.
//  Copyright © 2018 Wolox. All rights reserved.
//

import Foundation
import MBProgressHUD
import ReactiveSwift

extension Action {
    
    /**
     Displays a loading icon in the given view while the action is executing
     
     - parameter view: the view in which the loading icon will be displayed
    */
    public func bindLoading(view: UIView) {
        self.isExecuting.signal.observe(on: UIScheduler()).observeValues { isExecuting in
            if isExecuting {
                MBProgressHUD.showAdded(to: view, animated: true)
            } else {
                MBProgressHUD.hide(for: view, animated: true)
            }
        }
    }
    
    /**
     Changes the alpha component of the given button depending on the isEnabled value of the action
     
     - parameter button: the button that should be modified.
     */
    public func bindDisabled(button: UIButton) {
        self.isEnabled.producer.observe(on: UIScheduler()).startWithValues { isEnabled in
            if isEnabled {
                button.backgroundColor = button.backgroundColor?.withAlphaComponent(1)
            } else {
                button.backgroundColor = button.backgroundColor?.withAlphaComponent(0.5)
            }
        }
    }
}

