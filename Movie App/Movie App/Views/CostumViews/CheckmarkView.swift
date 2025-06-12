//
//  CheckmarkView.swift
//  Movie App
//
//  Created by Bryan Zweiacker on 12.06.2025.
//

import Foundation
import UIKit

class CheckmarkView: UIView {
    
    // MARK: - Constants
    
    private enum Constants {
        static let lineWidth: CGFloat = 5
        static let animationDuration: TimeInterval = 0.5
        static let pulseAnimationDuration: TimeInterval = 0.3
        static let pulseScale: CGFloat = 1.2
    }
    
    // MARK: - Properties
    
    private let checkmarkLayer = CAShapeLayer()
    
    // MARK: - Initializers
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }
    
    // MARK: - Lifecycle
    
    override func layoutSubviews() {
        super.layoutSubviews()
        updatePath()
    }
    
    // MARK: - Setup
    
    private func setup() {
        configureLayer()
        updatePath()
    }
    
    private func configureLayer() {
        checkmarkLayer.fillColor = nil
        checkmarkLayer.strokeColor = UIColor.white.cgColor
        checkmarkLayer.lineWidth = Constants.lineWidth
        checkmarkLayer.lineCap = .round
        checkmarkLayer.lineJoin = .round
        checkmarkLayer.strokeEnd = 0
        
        layer.addSublayer(checkmarkLayer)
    }
    
    private func updatePath() {
        let path = UIBezierPath()
        path.move(to: CGPoint(x: bounds.width * 0.25, y: bounds.height * 0.5))
        path.addLine(to: CGPoint(x: bounds.width * 0.45, y: bounds.height * 0.7))
        path.addLine(to: CGPoint(x: bounds.width * 0.75, y: bounds.height * 0.3))
        checkmarkLayer.path = path.cgPath
    }
    
    // MARK: - Public Methods
    
    func animate(completion: (() -> Void)? = nil) {
        let strokeAnimation = createStrokeAnimation()
        let animationDelegate = CheckmarkAnimationDelegate { [weak self] in
            self?.performPulseAnimation()
            completion?()
        }
        
        strokeAnimation.delegate = animationDelegate
        
        // Retain delegate to prevent deallocation
        objc_setAssociatedObject(
            checkmarkLayer,
            UnsafeRawPointer(bitPattern: 1)!,
            animationDelegate,
            .OBJC_ASSOCIATION_RETAIN_NONATOMIC
        )
        
        checkmarkLayer.strokeEnd = 1
        checkmarkLayer.add(strokeAnimation, forKey: "checkmarkAnimation")
    }
    
    func resetAnimation() {
        checkmarkLayer.removeAllAnimations()
        checkmarkLayer.strokeEnd = 0
        layer.removeAllAnimations()
        transform = .identity
    }
    
    // MARK: - Private Methods
    
    private func createStrokeAnimation() -> CABasicAnimation {
        let animation = CABasicAnimation(keyPath: "strokeEnd")
        animation.duration = Constants.animationDuration
        animation.fromValue = 0
        animation.toValue = 1
        animation.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
        animation.isRemovedOnCompletion = false
        animation.fillMode = .forwards
        return animation
    }
    
    private func performPulseAnimation() {
        let pulseAnimation = CAKeyframeAnimation(keyPath: "transform.scale")
        pulseAnimation.values = [1.0, Constants.pulseScale, 1.0]
        pulseAnimation.keyTimes = [0, 0.5, 1]
        pulseAnimation.duration = Constants.pulseAnimationDuration
        
        layer.add(pulseAnimation, forKey: "pulseAnimation")
    }
}

// MARK: - Customization

extension CheckmarkView {
    
    func setStrokeColor(_ color: UIColor) {
        checkmarkLayer.strokeColor = color.cgColor
    }
    
    func setLineWidth(_ width: CGFloat) {
        checkmarkLayer.lineWidth = width
    }
}
