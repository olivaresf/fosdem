import UIKit

final class TextViewController: UIViewController {
    var text: String? {
        get { textView.text }
        set { textView.text = newValue }
    }

    var attributedText: NSAttributedString? {
        get { textView.attributedText }
        set { textView.attributedText = newValue }
    }

    private lazy var textView = UITextView()

    override func loadView() {
        view = textView
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        textView.isEditable = false
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        let verticalInset: CGFloat = 20
        let horizontalInset = max(10, textView.readableContentGuide.layoutFrame.minX)

        textView.textContainerInset.top = verticalInset
        textView.textContainerInset.bottom = verticalInset
        textView.textContainerInset.left = horizontalInset
        textView.textContainerInset.right = horizontalInset
    }
}
