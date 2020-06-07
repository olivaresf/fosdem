import Foundation

enum MoreSection: CaseIterable {
  case years
  case recent
  case about
  case other
  #if DEBUG
  case debug
  #endif
}

extension MoreSection {
  var items: [MoreItem] {
    switch self {
    case .years:
      return [.years]
    case .recent:
      return [.video]
    case .other:
      return [.code, .acknowledgements]
    case .about:
      return [.history, .devrooms, .transportation]
    #if DEBUG
    case .debug:
      return [.time]
    #endif
    }
  }

  var title: String? {
    switch self {
    case .years:
      return NSLocalizedString("more.section.years", comment: "")
    case .recent:
      return NSLocalizedString("more.section.recent", comment: "")
    case .about:
      return NSLocalizedString("more.section.about", comment: "")
    case .other:
      return NSLocalizedString("more.section.other", comment: "")
    #if DEBUG
    case .debug:
      return "Debug"
    #endif
    }
  }
}
