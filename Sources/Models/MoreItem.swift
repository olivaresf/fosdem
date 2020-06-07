import UIKit

enum MoreItem: CaseIterable {
  #if DEBUG
  case time
  #endif

  case code
  case years
  case video
  case history
  case devrooms
  case transportation
  case acknowledgements
}

extension MoreItem {
  var title: String {
    switch self {
    case .code:
      return NSLocalizedString("code.title", comment: "")
    case .years:
      return NSLocalizedString("years.item", comment: "")
    case .video:
      return NSLocalizedString("recent.video", comment: "")
    case .history:
      return NSLocalizedString("history.title", comment: "")
    case .devrooms:
      return NSLocalizedString("devrooms.title", comment: "")
    case .transportation:
      return NSLocalizedString("transportation.title", comment: "")
    case .acknowledgements:
      return NSLocalizedString("acknowledgements.title", comment: "")
    #if DEBUG
    case .time:
      return NSLocalizedString("time.title", comment: "")
    #endif
    }
  }

  var icon: UIImage? {
    switch self {
    case .code:
      return UIImage(named: "contribute")
    case .years:
      return UIImage(named: "years")
    case .video:
      return UIImage(named: "video")
    case .history:
      return UIImage(named: "history")
    case .devrooms:
      return UIImage(named: "devrooms")
    case .transportation:
      return UIImage(named: "transportation")
    case .acknowledgements:
      return UIImage(named: "acknowledgements")
    #if DEBUG
    case .time:
      return nil
    #endif
    }
  }

  var info: Info? {
    switch self {
    case .history:
      return .history
    case .devrooms:
      return .devrooms
    case .transportation:
      return .transportation
    case .code, .years, .video, .acknowledgements:
      return nil
    #if DEBUG
    case .time:
      return nil
    #endif
    }
  }
}
