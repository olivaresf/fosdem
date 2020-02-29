import UIKit

final class TracksController: UINavigationController {
    private weak var tracksViewController: TracksViewController?
    private weak var eventsViewController: EventsViewController?

    private(set) var favoriteTracks: [Track] = []
    private(set) var tracksForDay: [[Track]] = []
    private(set) var tracks: [Track] = []

    private var observation: NSObjectProtocol?
    private var events: [Event] = []

    private let services: Services

    init(services: Services) {
        self.services = services
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private var activityService: ActivityService {
        services.activityService
    }

    private var favoritesService: FavoritesService {
        services.favoritesService
    }

    private var persistenceService: PersistenceService {
        services.persistenceService
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        let tracksViewController = makeTracksViewController()

        if #available(iOS 11.0, *) {
            navigationBar.prefersLargeTitles = true
        }

        viewControllers = [tracksViewController]

        activityService.attemptActivityRestoration { (activity: ViewEventsForTrackActivity) in
            self.events = activity.events
            pushViewController(makeEventsViewController(for: activity.track), animated: false)
        }

        activityService.attemptActivityRestoration { (activity: ViewEventForTrackActivity) in
            pushViewController(EventController(event: activity.event, services: services), animated: false)
        }

        persistenceService.tracks { result in
            DispatchQueue.main.async { [weak self] in
                switch result {
                case let .failure(error): self?.loadingDidFail(with: error)
                case let .success(tracks): self?.loadingDidFinish(with: tracks)
                }
            }
        }

        observation = favoritesService.addObserverForTracks { [weak self] in
            guard let self = self else { return }

            self.favoriteTracks = []
            for track in self.tracks where self.favoritesService.contains(track) {
                self.favoriteTracks.append(track)
            }
            self.favoriteTracks.sortByName()

            self.tracksViewController?.reloadFavorites()
        }
    }

    private func loadingDidFail(with _: Error) {
        viewControllers = [ErrorController()]
    }

    private func loadingDidFinish(with tracks: [Track]) {
        var tracksForDay: [Int: [Track]] = [:]
        for track in tracks {
            tracksForDay[track.day, default: []].append(track)

            if favoritesService.contains(track) {
                favoriteTracks.append(track)
            }
        }

        self.tracks = tracks
        self.tracks.sortByName()

        favoriteTracks.sortByName()

        self.tracksForDay = tracksForDay
            .sorted { lhs, rhs in lhs.key < rhs.key }
            .map { _, tracks in tracks }

        for i in self.tracksForDay.indices {
            self.tracksForDay[i].sortByName()
        }

        tracksViewController?.reloadData()
    }
}

extension TracksController: TracksViewControllerDataSource, TracksViewControllerDelegate {
    func tracksViewController(_: TracksViewController, didFavorite track: Track) {
        favoritesService.addTrack(withIdentifier: track.name)
    }

    func tracksViewController(_: TracksViewController, didUnfavorite track: Track) {
        favoritesService.removeTrack(withIdentifier: track.name)
    }

    func tracksViewController(_ tracksViewController: TracksViewController, didSelect track: Track) {
        tracksViewController.show(makeEventsViewController(for: track), sender: nil)

        events = []
        persistenceService.events(forTrackWithIdentifier: track.name) { result in
            DispatchQueue.main.async { [weak self] in
                switch result {
                case .failure:
                    self?.eventsViewController?.present(ErrorController(), animated: true)
                case let .success(events):
                    self?.events = events
                    self?.eventsViewController?.reloadData()

                    let activity = ViewEventsForTrackActivity(track: track, events: events)
                    self?.activityService.register(activity)
                }
            }
        }
    }
}

extension TracksController: EventsViewControllerDataSource, EventsViewControllerDelegate {
    func events(in _: EventsViewController) -> [Event] {
        events
    }

    func eventsViewController(_ eventsViewController: EventsViewController, didSelect event: Event) {
        eventsViewController.show(EventController(event: event, services: services), sender: nil)

        let activity = ViewEventForTrackActivity(event: event)
        activityService.register(activity)
    }
}

private extension TracksController {
    func makeTracksViewController() -> TracksViewController {
        let tracksViewController = TracksViewController()
        tracksViewController.title = NSLocalizedString("tracks.title", comment: "")
        tracksViewController.dataSource = self
        tracksViewController.delegate = self
        self.tracksViewController = tracksViewController

        if #available(iOS 11.0, *) {
            tracksViewController.navigationItem.largeTitleDisplayMode = .always
        }

        return tracksViewController
    }

    func makeEventsViewController(for track: Track) -> EventsViewController {
        let eventsViewController = EventsViewController(style: .grouped)
        eventsViewController.extendedLayoutIncludesOpaqueBars = true
        eventsViewController.hidesBottomBarWhenPushed = true
        eventsViewController.title = track.name
        eventsViewController.dataSource = self
        eventsViewController.delegate = self
        self.eventsViewController = eventsViewController

        if #available(iOS 11.0, *) {
            eventsViewController.navigationItem.largeTitleDisplayMode = .always
        }

        return eventsViewController
    }
}

private struct ViewEventsForTrackActivity: Activity, Codable {
    let track: Track
    let events: [Event]
}

private struct ViewEventForTrackActivity: Activity, Codable {
    let event: Event
}

private extension Array where Element == Track {
    mutating func sortByName() {
        sort { lhs, rhs in lhs.name < rhs.name }
    }
}
