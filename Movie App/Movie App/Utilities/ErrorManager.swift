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
    
    // MARK: - Alert Action Structure
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
    
    // MARK: - Public Methods
    
    /// Handles different types of errors and displays appropriate alerts
    /// - Parameters:
    ///   - error: The error to handle
    ///   - viewController: The view controller to present the alert in
    ///   - retryAction: Optional retry action closure
    func handleError(
        _ error: Error,
        in viewController: UIViewController,
        retryAction: (() -> Void)? = nil
    ) {
        logError(error)
        
        switch error {
        case let apiError as APIError:
            handleAPIError(apiError, in: viewController, retryAction: retryAction)
        case let dataError as DataError where dataError == .decodingError:
            handleDataError(dataError, in: viewController, retryAction: retryAction)
        default:
            handleGenericError(error, in: viewController, retryAction: retryAction)
        }
    }
    
    /// Shows a customizable alert dialog
    /// - Parameters:
    ///   - title: Alert title
    ///   - message: Alert message
    ///   - viewController: View controller to present in
    ///   - primaryAction: Primary action button
    ///   - secondaryAction: Optional secondary action button
    func showAlert(
        title: String,
        message: String,
        in viewController: UIViewController,
        primaryAction: AlertAction,
        secondaryAction: AlertAction? = nil
    ) {
        DispatchQueue.main.async {
            let alertController = UIAlertController(
                title: title,
                message: message,
                preferredStyle: .alert
            )
            
            let primaryUIAction = UIAlertAction(
                title: primaryAction.title,
                style: primaryAction.style
            ) { _ in
                primaryAction.handler?()
            }
            alertController.addAction(primaryUIAction)
            
            if let secondaryAction = secondaryAction {
                let secondaryUIAction = UIAlertAction(
                    title: secondaryAction.title,
                    style: secondaryAction.style
                ) { _ in
                    secondaryAction.handler?()
                }
                alertController.addAction(secondaryUIAction)
            }
            
            viewController.present(alertController, animated: true)
        }
    }
    
    // MARK: - Private Methods
    
    /// Handles API-specific errors
    private func handleAPIError(
        _ error: APIError,
        in viewController: UIViewController,
        retryAction: (() -> Void)?
    ) {
        switch error {
        case .networkError:
            showNetworkErrorAlert(in: viewController, retryAction: retryAction)
        case .unauthorized:
            showUnauthorizedErrorAlert(in: viewController)
        case .notFound:
            showNotFoundErrorAlert(in: viewController)
        default:
            showGenericAPIErrorAlert(in: viewController, retryAction: retryAction)
        }
    }
    
    /// Handles data processing errors
    private func handleDataError(
        _ error: DataError,
        in viewController: UIViewController,
        retryAction: (() -> Void)?
    ) {
        showAlert(
            title: NSLocalizedString("generalTitleErrorJSON", comment: ""),
            message: NSLocalizedString("generalMessageErrorJSON", comment: ""),
            in: viewController,
            primaryAction: AlertAction(
                title: NSLocalizedString("buttonRetry", comment: ""),
                handler: retryAction
            ),
            secondaryAction: AlertAction(
                title: NSLocalizedString("buttonCancel", comment: "")
            )
        )
    }
    
    /// Handles generic errors
    private func handleGenericError(
        _ error: Error,
        in viewController: UIViewController,
        retryAction: (() -> Void)?
    ) {
        showAlert(
            title: NSLocalizedString("generalTitleErrorGlobal", comment: ""),
            message: NSLocalizedString("generalMessageErrorGlobal", comment: ""),
            in: viewController,
            primaryAction: AlertAction(
                title: NSLocalizedString("buttonRetry", comment: ""),
                handler: retryAction
            ),
            secondaryAction: AlertAction(
                title: NSLocalizedString("buttonCancel", comment: "")
            )
        )
    }
    
    // MARK: - Specific Alert Methods
    
    private func showNetworkErrorAlert(
        in viewController: UIViewController,
        retryAction: (() -> Void)?
    ) {
        showAlert(
            title: NSLocalizedString("generalTitleErrorNetwork", comment: ""),
            message: NSLocalizedString("generalMessageErrorNetwork", comment: ""),
            in: viewController,
            primaryAction: AlertAction(
                title: NSLocalizedString("buttonRetry", comment: ""),
                handler: retryAction
            ),
            secondaryAction: AlertAction(
                title: NSLocalizedString("buttonCancel", comment: "")
            )
        )
    }
    
    private func showUnauthorizedErrorAlert(in viewController: UIViewController) {
        showAlert(
            title: NSLocalizedString("generalTitleAccessDenied", comment: ""),
            message: NSLocalizedString("generalMessageAccessDenied", comment: ""),
            in: viewController,
            primaryAction: AlertAction(
                title: NSLocalizedString("buttonCancel", comment: "")
            )
        )
    }
    
    private func showNotFoundErrorAlert(in viewController: UIViewController) {
        showAlert(
            title: NSLocalizedString("generalTitleErrorNotFound", comment: ""),
            message: NSLocalizedString("generalMessageErrorNotFound", comment: ""),
            in: viewController,
            primaryAction: AlertAction(
                title: NSLocalizedString("buttonCancel", comment: "")
            )
        )
    }
    
    private func showGenericAPIErrorAlert(
        in viewController: UIViewController,
        retryAction: (() -> Void)?
    ) {
        showAlert(
            title: NSLocalizedString("generalTitleErrorGlobal", comment: ""),
            message: NSLocalizedString("generalMessageErrorGlobal", comment: ""),
            in: viewController,
            primaryAction: AlertAction(
                title: NSLocalizedString("buttonRetry", comment: ""),
                handler: retryAction
            ),
            secondaryAction: AlertAction(
                title: NSLocalizedString("buttonCancel", comment: "")
            )
        )
    }
    
    /// Logs errors for debugging purposes
    private func logError(_ error: Error) {
        print("ERROR: \(error)")
    }
}
