//
//  ErrorManager.swift
//  Movie App
//
//  Created by Bryan Zweiacker on 22.04.2025.
//

import Foundation

import UIKit

class ErrorManager {
    
    // MARK: - Singleton
    static let shared = ErrorManager()
    private init() {}
    
    // MARK: - Struct Alert Actions
    struct AlertAction {
        let title: String
        let style: UIAlertAction.Style
        let handler: (() -> Void)?
        
        init(title: String, style: UIAlertAction.Style = .default, handler: (() -> Void)? = nil) {
            self.title = title
            self.style = style
            self.handler = handler
        }
    }
    
    // MARK: - Handle Error
    func handleError(_ error: Error, in viewController: UIViewController, retryAction: (() -> Void)? = nil) {
        logError(error)
        
        // Determine the type of error and display the appropriate alert
        if let apiError = error as? APIError {
            handleAPIError(apiError, in: viewController, retryAction: retryAction)
        } else if let dataError = error as? DataError, dataError == .decodingError {
            handleDataError(dataError, in: viewController, retryAction: retryAction)
        } else {
            handleGenericError(error, in: viewController, retryAction: retryAction)
        }
    }
    
    //MARK: - Show Alert
    func showAlert(
        title: String,
        message: String,
        in viewController: UIViewController,
        primaryAction: AlertAction,
        secondaryAction: AlertAction? = nil
    ) {
        DispatchQueue.main.async {
            let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
            
            let primaryUIAction = UIAlertAction(title: primaryAction.title, style: primaryAction.style) { _ in
                primaryAction.handler?()
            }
            alertController.addAction(primaryUIAction)
            
            if let secondaryAction = secondaryAction {
                let secondaryUIAction = UIAlertAction(title: secondaryAction.title, style: secondaryAction.style) { _ in
                    secondaryAction.handler?()
                }
                alertController.addAction(secondaryUIAction)
            }
            
            viewController.present(alertController, animated: true)
        }
    }
    
    // MARK: - Handle API Error
    private func handleAPIError(_ error: APIError, in viewController: UIViewController, retryAction: (() -> Void)?) {
        switch error {
            case .networkError:
                showAlert(
                    title: NSLocalizedString("generalTitleErrorNetwork", comment: ""),
                    message: NSLocalizedString("generalMessageErrorNetwork", comment: ""),
                    in: viewController,
                    primaryAction: AlertAction(
                        title: NSLocalizedString("buttonRetry", comment: ""),
                        handler: retryAction
                    ),
                    secondaryAction: AlertAction(
                        title: NSLocalizedString("buttonCancel", comment: ""))
                )
                
            case .unauthorized:
                showAlert(
                    title: NSLocalizedString("generalTitleAccessDenied", comment: ""),
                    message: NSLocalizedString("generalMessageAccessDenied", comment: ""),
                    in: viewController,
                    primaryAction: AlertAction(
                        title: NSLocalizedString("buttonCancel", comment: ""))
                )
                
            case .notFound:
                showAlert(
                    title: NSLocalizedString("generalTitleErrorNotFound", comment: ""),
                    message: NSLocalizedString("generalMessageErrorNotFound", comment: ""),
                    in: viewController,
                    primaryAction: AlertAction(
                        title: NSLocalizedString("buttonCancel", comment: ""))
                )
                
            default:
                showAlert(
                    title: NSLocalizedString("generalTitleErrorGlobal", comment: ""),
                    message: NSLocalizedString("generalMessageErrorGlobal", comment: ""),
                    in: viewController,
                    primaryAction: AlertAction(
                        title: NSLocalizedString("buttonRetry", comment: ""),
                        handler: retryAction
                    ),
                    secondaryAction: AlertAction(
                        title: NSLocalizedString("buttonCancel", comment: ""))
                )
            }
    }
    
    //MARK: - Handle Data Error
    private func handleDataError(_ error: DataError, in viewController: UIViewController, retryAction: (() -> Void)?) {
        showAlert(
            title: NSLocalizedString("generalTitleErrorJSON", comment: ""),
            message: NSLocalizedString("generalMessageErrorJSON", comment: ""),
            in: viewController,
            primaryAction: AlertAction(
                title: NSLocalizedString("buttonRetry", comment: ""),
                handler: retryAction
            ),
            secondaryAction: AlertAction(
                title: NSLocalizedString("buttonCancel", comment: ""))
        )
    }
    
    private func handleGenericError(_ error: Error, in viewController: UIViewController, retryAction: (() -> Void)?) {
        showAlert(
            title: NSLocalizedString("generalTitleErrorGlobal", comment: ""),
            message: NSLocalizedString("generalMessageErrorGlobal", comment: ""),
            in: viewController,
            primaryAction: AlertAction(
                title: NSLocalizedString("buttonRetry", comment: ""),
                handler: retryAction
            ),
            secondaryAction: AlertAction(
                title: NSLocalizedString("buttonCancel", comment: ""))
        )
    }
    
    //MARK: - Log Error
    private func logError(_ error: Error) {
        print("ERROR: \(error)")
    }
}
