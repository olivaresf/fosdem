import UIKit

protocol EventViewDelegate: AnyObject {
    func eventViewDidTapVideo(_ eventView: EventView)
    func eventView(_ eventView: EventView, didSelect attachment: Attachment)
}

final class EventView: UIStackView {
    weak var delegate: EventViewDelegate?

    var event: Event? {
        didSet { didChangeEvent() }
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        axis = .vertical
        spacing = 10
    }

    required init(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func didChangeEvent() {
        for subview in arrangedSubviews {
            removeArrangedSubview(subview)
            subview.removeFromSuperview()
        }

        guard let event = event else { return }

        let titleLabel = UILabel()
        titleLabel.font = .fos_preferredFont(forTextStyle: .title1, withSymbolicTraits: .traitBold)
        titleLabel.text = event.title
        titleLabel.numberOfLines = 0
        addArrangedSubview(titleLabel)

        let trackLabel = UILabel()
        trackLabel.font = .fos_preferredFont(forTextStyle: .title3, withSymbolicTraits: .traitBold)
        trackLabel.text = event.track
        trackLabel.numberOfLines = 0
        addArrangedSubview(trackLabel)

        if event.video != nil {
            let videoTitle = NSLocalizedString("event.video", comment: "")
            let videoAction = #selector(didTapVideo)
            let videoButton = RoundedButton()
            videoButton.accessibilityLabel = NSLocalizedString("event.video.accessibility", comment: "")
            videoButton.addTarget(self, action: videoAction, for: .touchUpInside)
            videoButton.setTitle(videoTitle, for: .normal)
            addArrangedSubview(videoButton)
        }

        if !event.people.isEmpty {
            let peopleView = EventMetadataView()
            peopleView.image = .fos_systemImage(withName: "person.fill")
            peopleView.text = event.formattedPeople
            addArrangedSubview(peopleView)
        }

        let roomFormat = NSLocalizedString("event.room", comment: "")
        let roomLabel = String(format: roomFormat, event.room)

        let roomView = EventMetadataView()
        roomView.image = .fos_systemImage(withName: "mappin.circle.fill")
        roomView.accessibilityLabel = roomLabel
        roomView.text = event.room
        addArrangedSubview(roomView)

        let dateView = EventMetadataView()
        dateView.image = .fos_systemImage(withName: "clock.fill")
        dateView.text = event.formattedDate
        addArrangedSubview(dateView)

        if let subtitle = event.subtitle {
            let subtitleLabel = UILabel()
            subtitleLabel.font = .fos_preferredFont(forTextStyle: .headline)
            subtitleLabel.numberOfLines = 0
            subtitleLabel.text = subtitle
            addArrangedSubview(subtitleLabel)
        }

        if let abstract = event.formattedAbstract {
            let abstractLabel = UILabel()
            abstractLabel.font = .fos_preferredFont(forTextStyle: .body)
            abstractLabel.numberOfLines = 0
            abstractLabel.text = abstract
            addArrangedSubview(abstractLabel)
        }

        if let summary = event.formattedSummary {
            let summaryLabel = UILabel()
            summaryLabel.font = .fos_preferredFont(forTextStyle: .body)
            summaryLabel.numberOfLines = 0
            summaryLabel.text = summary
            addArrangedSubview(summaryLabel)
        }

        let attachments = event.attachments.filter(EventAttachmentView.canDisplay)

        if !attachments.isEmpty {
            let attachmentsLabel = UILabel()
            attachmentsLabel.text = NSLocalizedString("event.attachments", comment: "")
            attachmentsLabel.font = .fos_preferredFont(forTextStyle: .headline)
            attachmentsLabel.numberOfLines = 0
            addArrangedSubview(attachmentsLabel)
        }

        for attachment in attachments {
            let attachmentAction = #selector(didTapAttachment(_:))
            let attachmentView = EventAttachmentView()
            attachmentView.accessibilityTraits = .link
            attachmentView.attachment = attachment
            attachmentView.addTarget(self, action: attachmentAction, for: .touchUpInside)
            addArrangedSubview(attachmentView)
        }
    }

    @objc private func didTapVideo() {
        delegate?.eventViewDidTapVideo(self)
    }

    @objc private func didTapAttachment(_ attachmentView: EventAttachmentView) {
        if let attachment = attachmentView.attachment {
            delegate?.eventView(self, didSelect: attachment)
        }
    }
}
