//
//  WebViewController.swift
//  Athelo
//
//  Created by Krzysztof Jabłoński on 21/06/2022.
//

import UIKit
import WebKit

protocol WebViewControllerDelegate: AnyObject {
    func webViewControllerAsksToDecidePolicyForDeeplink(_ deeplink: DeeplinkType) -> Bool
}

final class WebViewController: BaseViewController {
    // MARK: - Outlets
    @IBOutlet private weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet private weak var buttonBack: UIBarButtonItem!
    @IBOutlet private weak var buttonForward: UIBarButtonItem!
    @IBOutlet private weak var toolbar: UIToolbar!
    @IBOutlet private weak var webView: WKWebView?
    
    // MARK: - Properties
    private var configurationData: ConfigurationData?
    
    override var modalPresentationStyle: UIModalPresentationStyle {
        get { .formSheet }
        set { /* ... */ }
    }
    
    // MARK: - View lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureWebView()
    }
    
    deinit {
        webView?.uiDelegate = nil
        webView?.navigationDelegate = nil
        webView?.scrollView.delegate = nil
        webView?.stopLoading()
    }
    
    // MARK: - Configuration
    private func configure() {
        configureWebView()
    }
    
    private func configureWebView() {
        guard webView == nil else {
            return
        }
        
        let configuration = WKWebViewConfiguration()
        configuration.websiteDataStore = configurationData?.privateSession == true ? .nonPersistent() : .default()
        
        let webView = WKWebView(frame: view.bounds, configuration: configuration)
        
        
        webView.translatesAutoresizingMaskIntoConstraints = false
        view.insertSubview(webView, at: 0)
        
        NSLayoutConstraint.activate([
            webView.topAnchor.constraint(equalTo: view.topAnchor),
            webView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            webView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            webView.bottomAnchor.constraint(equalTo: toolbar.topAnchor)
        ])
        
        self.webView = webView
        
        self.webView?.navigationDelegate = self
        self.webView?.uiDelegate = self
        
        if let url = configurationData?.url {
            self.webView?.load(.init(url: url))
        }
    }
    
    // MARK: - Updates
    private func updateNavigationButtons() {
        buttonBack.isEnabled = webView?.canGoBack == true
        buttonForward.isEnabled = webView?.canGoForward == true
    }
    
    // MARK: - Actions
    @IBAction private func backButtonTapped(_ sender: Any) {
        if webView?.canGoBack == true {
            webView?.goBack()
        }
    }
    
    @IBAction private func doneButtonTapped(_ sender: Any) {
        if presentingViewController != nil {
            dismiss(animated: true)
        } else if navigationController != nil {
            navigationController?.popViewController(animated: true)
        }
    }
    
    @IBAction func forwardButotnTapped(_ sender: Any) {
        if webView?.canGoForward == true {
            webView?.goForward()
        }
    }
    
    @IBAction private func refreshButtonTapped(_ sender: Any) {
        webView?.reload()
    }
}

// MARK: - Protocol conformance
// MARK: Configurable
extension WebViewController: Configurable {
    final class ConfigurationData {
        let url: URL
        let privateSession: Bool
        private(set) weak var delegate: WebViewControllerDelegate?
        
        init(url: URL, privateSession: Bool = false, delegate: WebViewControllerDelegate? = nil) {
            self.url = url
            self.privateSession = privateSession
            self.delegate = delegate
        }
    }
    
    typealias ConfigurationDataType = ConfigurationData
    
    func assignConfigurationData(_ configurationData: ConfigurationData) {
        self.configurationData = configurationData
    }
}

// MARK: Navigable
extension WebViewController: Navigable {
    static var storyboardScene: StoryboardScene {
        .web
    }
}

// MARK: WKNavigationDelegate
extension WebViewController: WKNavigationDelegate {
    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        activityIndicator.startAnimating()
        updateNavigationButtons()
    }

    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        activityIndicator.stopAnimating()
        updateNavigationButtons()
    }

    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        activityIndicator.stopAnimating()
        updateNavigationButtons()
    }

    func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
        activityIndicator.stopAnimating()
        updateNavigationButtons()
    }

    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        if let url = navigationAction.request.url, let deeplink = DeeplinkType(deeplink: url) {
            if configurationData?.delegate?.webViewControllerAsksToDecidePolicyForDeeplink(deeplink) == true {
                decisionHandler(.cancel)
                dismiss(animated: true)
                
                return
            }
        }

        if [.linkActivated, .other].contains(navigationAction.navigationType),
            let preparedUrl: URL = navigationAction.request.url,
            ["tel", "mailto", "webcal"].contains(preparedUrl.scheme) || preparedUrl.host?.lowercased() == "itunes.apple.com" {
            UIApplication.shared.open(preparedUrl, options: [:], completionHandler: nil)
            decisionHandler(.cancel)
        } else {
            decisionHandler(.allow)
        }
    }

    func webView(_ webView: WKWebView, createWebViewWith configuration: WKWebViewConfiguration, for navigationAction: WKNavigationAction, windowFeatures: WKWindowFeatures) -> WKWebView? {        
        if navigationAction.targetFrame == nil, let url: URL = navigationAction.request.url {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        }

        return nil
    }
}

// MARK: WKUIDelegate
extension WebViewController: WKUIDelegate {
    /* ... */
}
