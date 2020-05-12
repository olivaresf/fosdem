import Foundation

struct Event: Codable {
    let id: Int
    let room: String
    let track: String

    let title: String
    let summary: String?
    let subtitle: String?
    let abstract: String?

    let date: Date
    let start: DateComponents
    let duration: DateComponents

    let links: [Link]
    let people: [Person]
    let attachments: [Attachment]
}

extension Event {
    var video: Link? {
        links.first { link in link.url?.pathExtension == "mp4" }
    }

    func isLive(at timestamp: Date) -> Bool {
        let calendar = Calendar.autoupdatingCurrent
        let lowerbound = date
        let upperbound = calendar.date(byAdding: duration, to: date) ?? .distantPast
        return lowerbound < timestamp && timestamp < upperbound
    }

    func isSameWeekday(as event: Event) -> Bool {
        let lhs = Calendar.autoupdatingCurrent.component(.weekday, from: date)
        let rhs = Calendar.autoupdatingCurrent.component(.weekday, from: event.date)
        return lhs == rhs
    }
}

extension Event {
    var formattedStart: String? {
        DateComponentsFormatter.time.string(from: start)
    }

    var formattedWeekday: String? {
        DateFormatter.weekday.string(from: date)
    }

    var formattedStartWithWeekday: String? {
        switch (formattedStart, formattedWeekday) {
        case (nil, _):
            return nil
        case let (start?, nil):
            return start
        case let (start?, weekday?):
            let format = NSLocalizedString("search.event.start", comment: "")
            let string = String(format: format, start, weekday)
            return string
        }
    }

    var formattedAbstract: String? {
        guard let abstract = abstract, let html = abstract.data(using: .utf8), let attributedString = try? NSAttributedString.fromHTML(html) else { return nil }

        var string = attributedString.string
        string = string.trimmingCharacters(in: .whitespacesAndNewlines)
        string = string.replacingOccurrences(of: "\n", with: "\n\n")
        return string
    }

    var formattedSummary: String? {
        summary?.replacingOccurrences(of: "\n", with: "\n\n")
    }

    var formattedPeople: String? {
        people.map { person in person.name }.joined(separator: ", ")
    }

    var formattedDuration: String? {
        DateComponentsFormatter.duration.string(from: duration)
    }

    var formattedDate: String? {
        var items: [String] = []

        if let start = formattedStart {
            items.append(start)
        }

        if let weekday = formattedWeekday {
            let format = NSLocalizedString("event.weekday", comment: weekday)
            let string = String(format: format, weekday)
            items.append(string)
        }

        if let duration = formattedDuration {
            items.append("(\(duration) minutes)")
        }

        if items.isEmpty {
            return nil
        } else {
            return items.joined(separator: " ")
        }
    }
}

extension Event: Hashable, Equatable {
    static func == (lhs: Event, rhs: Event) -> Bool {
        lhs.id == rhs.id
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}
