import UIKit

final class VideosController: UIPageViewController {
  private lazy var watchingViewController = makeEventsViewController()
  private lazy var watchedViewController = makeEventsViewController()
  private lazy var segmentedControl = UISegmentedControl()

  private var watchingEvents: [Event] = []
  private var watchedEvents: [Event] = []

  private let services: Services

  init(services: Services) {
    self.services = services
    super.init(transitionStyle: .scroll, navigationOrientation: .horizontal)
  }

  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  override func viewDidLoad() {
    super.viewDidLoad()

    view.backgroundColor = .fos_systemBackground

    let item1 = NSLocalizedString("recent.video.watching", comment: "")
    let item2 = NSLocalizedString("recent.video.watched", comment: "")

    watchingViewController.title = item1
    watchedViewController.title = item2
    setViewControllers([watchedViewController], direction: .forward, animated: false)

    let segmentedAction = #selector(didChangeSegment(_:))
    segmentedControl.addTarget(self, action: segmentedAction, for: .valueChanged)
    segmentedControl.insertSegment(withTitle: item1, at: 0, animated: false)
    segmentedControl.insertSegment(withTitle: item2, at: 1, animated: false)
    segmentedControl.selectedSegmentIndex = 0
    navigationItem.titleView = segmentedControl
    navigationItem.largeTitleDisplayMode = .never

    let watchedIdentifiers = services.playbackService.watched
    let watchedOperation = EventsForIdentifiers(identifiers: watchedIdentifiers)
    services.persistenceService.performRead(watchedOperation) { [weak self] result in
      DispatchQueue.main.async {
        switch result {
        case .failure:
          break
        case let .success(events):
          self?.watchedEvents = events
          self?.watchedViewController.reloadData()
        }
      }
    }

    let watchingIdentifiers = services.playbackService.watching
    let watchingOperation = EventsForIdentifiers(identifiers: watchingIdentifiers)
    services.persistenceService.performRead(watchingOperation) { [weak self] result in
      DispatchQueue.main.async {
        switch result {
        case .failure:
          break
        case let .success(events):
          self?.watchingEvents = events
          self?.watchingViewController.reloadData()
        }
      }
    }
  }

  @objc private func didChangeSegment(_ control: UISegmentedControl) {
    switch control.selectedSegmentIndex {
    case 0:
      setViewControllers([watchedViewController], direction: .reverse, animated: true)
    case 1:
      setViewControllers([watchingViewController], direction: .forward, animated: true)
    default:
      break
    }
  }
}

extension VideosController: EventsViewControllerDataSource, EventsViewControllerDelegate {
  func events(in eventsViewController: EventsViewController) -> [Event] {
    switch eventsViewController {
    case watchingViewController:
      return watchingEvents
    case watchedViewController:
      return watchedEvents
    default:
      return []
    }
  }

  func eventsViewController(_ eventsViewController: EventsViewController, captionFor event: Event) -> String? {
    event.formattedPeople
  }

  func eventsViewController(_ eventsViewController: EventsViewController, didSelect event: Event) {
    let eventViewController = makeEventViewController(for: event)
    show(eventViewController, sender: nil)
  }
}

extension VideosController: UIPageViewControllerDataSource {
  func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
    switch viewController {
    case watchingViewController:
      return nil
    case watchedViewController:
      return watchingViewController
    default:
      return nil
    }
  }

  func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
    switch viewController {
    case watchingViewController:
      return watchedViewController
    case watchedViewController:
      return nil
    default:
      return nil
    }
  }
}

extension VideosController: UIPageViewControllerDelegate {
  func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
    guard completed else { return }

    switch pageViewController.viewControllers?.first {
    case watchingViewController:
      segmentedControl.selectedSegmentIndex = 0
    case watchedViewController:
      segmentedControl.selectedSegmentIndex = 1
    default:
      break
    }
  }
}

private extension VideosController {
  func makeEventsViewController() -> EventsViewController {
    let eventsViewController = EventsViewController(style: .grouped)
    eventsViewController.navigationItem.largeTitleDisplayMode = .never
    eventsViewController.dataSource = self
    eventsViewController.delegate = self
    return eventsViewController
  }

  func makeEventViewController(for event: Event) -> EventController {
    EventController(event: event, services: services)
  }
}
