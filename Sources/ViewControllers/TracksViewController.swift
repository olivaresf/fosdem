import UIKit

protocol TracksViewControllerDataSource: AnyObject {
    func numberOfSections(in tracksViewController: TracksViewController) -> Int
    func tracksViewController(_ tracksViewController: TracksViewController, titleForSectionAt section: Int) -> String?
    func tracksViewController(_ tracksViewController: TracksViewController, numberOfTracksIn section: Int) -> Int
    func tracksViewController(_ tracksViewController: TracksViewController, trackAt indexPath: IndexPath) -> Track
}

protocol TracksViewControllerFavoritesDataSource: AnyObject {
    func tracksViewController(_ tracksViewController: TracksViewController, canFavorite track: Track) -> Bool
}

protocol TracksViewControllerDelegate: AnyObject {
    func tracksViewController(_ tracksViewController: TracksViewController, didSelect track: Track)
}

protocol TracksViewControllerFavoritesDelegate: AnyObject {
    func tracksViewController(_ tracksViewController: TracksViewController, didFavorite track: Track)
    func tracksViewController(_ tracksViewController: TracksViewController, didUnfavorite track: Track)
}

final class TracksViewController: UITableViewController {
    weak var dataSource: TracksViewControllerDataSource?
    weak var delegate: TracksViewControllerDelegate?

    weak var favoritesDataSource: TracksViewControllerFavoritesDataSource?
    weak var favoritesDelegate: TracksViewControllerFavoritesDelegate?

    private lazy var tableBackgroundView = TableBackgroundView()

    var selectedTrack: Track? {
        if let indexPath = tableView.indexPathForSelectedRow {
            return dataSource?.tracksViewController(self, trackAt: indexPath)
        } else {
            return nil
        }
    }

    func reloadData() {
        if isViewLoaded {
            tableView.reloadData()
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.tableFooterView = UIView()
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: UITableViewCell.reuseIdentifier)
        tableBackgroundView.text = NSLocalizedString("search.empty", comment: "")
    }

    override func numberOfSections(in _: UITableView) -> Int {
        let count = dataSource?.numberOfSections(in: self) ?? 0
        tableView.backgroundView = count == 0 ? tableBackgroundView : nil
        return count
    }

    override func tableView(_: UITableView, titleForHeaderInSection section: Int) -> String? {
        dataSource?.tracksViewController(self, titleForSectionAt: section)
    }

    override func tableView(_: UITableView, numberOfRowsInSection section: Int) -> Int {
        dataSource?.tracksViewController(self, numberOfTracksIn: section) ?? 0
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: UITableViewCell.reuseIdentifier, for: indexPath)
        if let track = dataSource?.tracksViewController(self, trackAt: indexPath) {
            cell.configure(with: track)
        }
        return cell
    }

    override func tableView(_: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let track = dataSource?.tracksViewController(self, trackAt: indexPath) {
            delegate?.tracksViewController(self, didSelect: track)
        }
    }

    override func tableView(_: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        guard let dataSource = dataSource, let favoritesDataSource = favoritesDataSource else { return nil }

        let track = dataSource.tracksViewController(self, trackAt: indexPath)

        if favoritesDataSource.tracksViewController(self, canFavorite: track) {
            return [.favorite { [weak self] _ in self?.didFavoriteTrack(track) }]
        } else {
            return [.unfavorite { [weak self] _ in self?.didUnfavoriteTrack(track) }]
        }
    }

    private func didFavoriteTrack(_ track: Track) {
        favoritesDelegate?.tracksViewController(self, didFavorite: track)
    }

    private func didUnfavoriteTrack(_ track: Track) {
        favoritesDelegate?.tracksViewController(self, didUnfavorite: track)
    }
}

private extension UITableViewCell {
    func configure(with track: Track) {
        textLabel?.text = track.name
        accessoryType = .disclosureIndicator
    }
}
