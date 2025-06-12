//
//  KeyboardInsetHandler.swift
//  Routory
//
//  Created by tlswo on 6/12/25.
//

import UIKit

final class KeyboardInsetHandler {
    private weak var scrollView: UIScrollView?
    private weak var containerView: UIView?
    private weak var targetView: UIView?  

    init(scrollView: UIScrollView, containerView: UIView, targetView: UIView? = nil) {
        self.scrollView = scrollView
        self.containerView = containerView
        self.targetView = targetView
    }

    func startObserving() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillShow(_:)),
            name: UIResponder.keyboardWillShowNotification,
            object: nil
        )
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillHide(_:)),
            name: UIResponder.keyboardWillHideNotification,
            object: nil
        )
    }

    func stopObserving() {
        NotificationCenter.default.removeObserver(self)
    }

    @objc private func keyboardWillShow(_ notification: Notification) {
        guard
            let scrollView = scrollView,
            let containerView = containerView,
            let userInfo = notification.userInfo,
            let keyboardFrame = userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect
        else { return }

        let keyboardHeight = keyboardFrame.height
        scrollView.contentInset.bottom = keyboardHeight + 16
        scrollView.verticalScrollIndicatorInsets.bottom = keyboardHeight + 16

        if let targetView = targetView,
           let targetFrame = targetView.superview?.convert(targetView.frame, to: containerView) {
            scrollView.scrollRectToVisible(targetFrame, animated: true)
        }
    }

    @objc private func keyboardWillHide(_ notification: Notification) {
        scrollView?.contentInset.bottom = 0
        scrollView?.verticalScrollIndicatorInsets.bottom = 0
    }
}
