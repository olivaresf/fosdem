import UIKit

protocol EventsSearchController: UIViewController {
  var results: [Event] { get set }
  var resultsViewController: EventsViewController? { get }
  var persistenceService: PersistenceService { get }
}

extension EventsSearchController {
  func didChangeQuery(_ query: String) {
    guard query.count >= 3 else {
      results = []
      resultsViewController?.configure(with: .noQuery)
      resultsViewController?.reloadData()
      return
    }

    let operation = EventsForSearch(query: query)
    persistenceService.performRead(operation) { [weak self] result in
      DispatchQueue.main.async {
        switch result {
        case .failure:
          self?.results = []
          self?.resultsViewController?.configure(with: .failure(query: query))
          self?.resultsViewController?.reloadData()
        case let .success(events):
          self?.results = events
          self?.resultsViewController?.configure(with: .success(query: query))
          self?.resultsViewController?.reloadData()
        }
      }
    }
  }
}

private extension EventsViewController {
  enum Configuration {
    case noQuery
    case success(query: String)
    case failure(query: String)
  }

  func configure(with configuration: Configuration) {
    view.isHidden = configuration.isViewHidden
    emptyBackgroundTitle = configuration.emptyBackgroundTitle
    emptyBackgroundMessage = configuration.emptyBackgroundMessage
  }
}

extension EventsViewController.Configuration {
  var emptyBackgroundTitle: String? {
    switch self {
    case .noQuery:
      return nil
    case .failure:
      return FOSLocalizedString("search.error.title")
    case .success:
      return FOSLocalizedString("search.empty.title")
    }
  }

  var emptyBackgroundMessage: String? {
    switch self {
    case .noQuery:
      return nil
    case .failure:
      return FOSLocalizedString("search.error.message")
    case let .success(query):
      return FOSLocalizedString(format: "search.empty.message", query)
    }
  }

  var isViewHidden: Bool {
    switch self {
    case .noQuery:
      return true
    case .success, .failure:
      return false
    }
  }
}
