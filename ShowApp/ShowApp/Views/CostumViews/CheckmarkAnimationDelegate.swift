//
//  CheckmarkAnimationDelegate.swift
//  ShowApp
//
//  Created by Bryan Zweiacker on 12.06.2025.
//

import Foundation
import UIKit

class CheckmarkAnimationDelegate: NSObject, CAAnimationDelegate {
    
    // MARK: - Properties
    
    private let completion: () -> Void
    
    // MARK: - Initializer
    
    init(completion: @escaping () -> Void) {
        self.completion = completion
        super.init()
    }
    
    // MARK: - CAAnimationDelegate
    
    func animationDidStop(_ anim: CAAnimation, finished flag: Bool) {
        guard flag else { return }
        completion()
    }
    
    func animationDidStart(_ anim: CAAnimation) {
        // Override if needed for additional functionality
    }
}
