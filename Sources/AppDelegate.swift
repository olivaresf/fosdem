import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
  var window: UIWindow?

  private var pendingNetworkRequests = 0 {
    didSet { didChangePendingNetworkRequests() }
  }

  private var applicationController: ApplicationController? {
    window?.rootViewController as? ApplicationController
  }

  func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil) -> Bool {
    #if DEBUG
    if ProcessInfo.processInfo.isRunningUnitTests {
      return false
    }
    #endif

    let rootViewController: UIViewController
    do {
      rootViewController = ApplicationController(services: try makeServices())
    } catch {
      rootViewController = makeErrorViewController()
    }

    let window = UIWindow()
    window.tintColor = .fos_label
    window.rootViewController = rootViewController
    window.makeKeyAndVisible()
    self.window = window

    #if DEBUG
    if ProcessInfo.processInfo.isRunningUITests {
      window.layer.speed = 100
    }
    #endif

    return true
  }

  func applicationDidBecomeActive(_ application: UIApplication) {
    applicationController?.applicationDidBecomeActive()
  }

  func applicationWillResignActive(_ application: UIApplication) {
    applicationController?.applicationWillResignActive()
  }

  private func didChangePendingNetworkRequests() {
    #if !targetEnvironment(macCatalyst)
    UIApplication.shared.isNetworkActivityIndicatorVisible = pendingNetworkRequests > 0
    #endif
  }

  private func makeServices() throws -> Services {
    let services = try Services()
    services.networkService.delegate = self
    return services
  }

  func makeErrorViewController() -> ErrorViewController {
    let errorViewController = ErrorViewController()
    errorViewController.showsAppStoreButton = true
    return errorViewController
  }
}

extension AppDelegate: NetworkServiceDelegate {
  func networkServiceDidBeginRequest(_ networkService: NetworkService) {
    OperationQueue.main.addOperation { [weak self] in
      self?.pendingNetworkRequests += 1
    }
  }

  func networkServiceDidEndRequest(_ networkService: NetworkService) {
    OperationQueue.main.addOperation { [weak self] in
      self?.pendingNetworkRequests -= 1
    }
  }
}
