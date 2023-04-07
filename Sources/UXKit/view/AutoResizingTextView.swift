// © GHOZT

import UIKit

open class AutoResizingTextView: UITextView, StateMachineDelegate {

  public enum ResizeBehavior: Equatable {
    case matchContent(min: CGFloat = 0, max: CGFloat = .infinity)
    case none
  }

  private let placeholderLabel = UILabel()
  private weak var placeholderLabelConstraintX: NSLayoutConstraint?
  private weak var placeholderLabelConstraintY: NSLayoutConstraint?

  lazy public var stateMachine = StateMachine(self)
  @Stateful public var horizontalResizeBehavior: ResizeBehavior = .none
  @Stateful public var verticalResizeBehavior: ResizeBehavior = .none
  @Stateful public var placeholder: String?
  @Stateful public var placeholderAlpha: CGFloat = 0.6
  @Stateful public var placeholderTextColor: UIColor?

  open override var intrinsicContentSize: CGSize {
    var size = super.intrinsicContentSize

    switch horizontalResizeBehavior {
    case let .matchContent(min, max):
      size.width = (min...max).clamp(contentSize.width)
    case .none:
      break
    }

    switch verticalResizeBehavior {
    case let .matchContent(min, max):
      size.height = (min...max).clamp(contentSize.height)
    case .none:
      break
    }

    return size
  }

  public override init(frame: CGRect, textContainer: NSTextContainer?) {
    super.init(frame: frame, textContainer: textContainer)

    loadSubviews()
    stateMachine.start()
  }

  required public init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)

    loadSubviews()
    stateMachine.start()
  }

  func loadSubviews() {
    backgroundColor = .clear
    addObserver(self, forKeyPath: "contentSize", options: .new, context: nil)
    addObserver(self, forKeyPath: "font", options: .new, context: nil)
    addObserver(self, forKeyPath: "text", options: .new, context: nil)
    addObserver(self, forKeyPath: "textContainerInset", options: .new, context: nil)
    addObserver(self, forKeyPath: "textColor", options: .new, context: nil)

    NotificationCenter.default.addObserver(self, selector: #selector(onTextChange), name: UITextView.textDidChangeNotification, object: nil)

    addSubview(placeholderLabel) {
      $0.isUserInteractionEnabled = false
      $0.autoLayout {
        self.placeholderLabelConstraintX = $0.alignToSuperview(.left).first
        self.placeholderLabelConstraintY = $0.alignToSuperview(.top).first
      }
    }
  }

  deinit {
    stateMachine.stop()

    NotificationCenter.default.removeObserver(self)

    removeObserver(self, forKeyPath: "textContainerInset")
    removeObserver(self, forKeyPath: "font")
    removeObserver(self, forKeyPath: "text")
    removeObserver(self, forKeyPath: "textColor")
    removeObserver(self, forKeyPath: "contentSize")
  }

  public override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey: Any]?, context: UnsafeMutableRawPointer?) {
    switch object {
    case is UITextView:
      switch keyPath {
      case "contentSize":
        if case .matchContent = horizontalResizeBehavior {
          stateMachine.invalidate(\AutoResizingTextView.horizontalResizeBehavior)
        }
        else if case .matchContent = verticalResizeBehavior {
          stateMachine.invalidate(\AutoResizingTextView.verticalResizeBehavior)
        }
      case "font":
        stateMachine.invalidate(\AutoResizingTextView.font)
      case "text":
        stateMachine.invalidate(\AutoResizingTextView.text)
      case "textColor":
        stateMachine.invalidate(\AutoResizingTextView.textColor)
      case "textContainerInset":
        stateMachine.invalidate(\AutoResizingTextView.textContainerInset)
      default:
        break
      }
    default:
      break
    }
  }

  @objc private func onTextChange() {
    stateMachine.invalidate(\AutoResizingTextView.text)
  }

  public func update(check: StateValidator) {
    if check.isDirty(\AutoResizingTextView.horizontalResizeBehavior, \AutoResizingTextView.verticalResizeBehavior) {
      invalidateIntrinsicContentSize()
    }

    if check.isDirty(\AutoResizingTextView.font) {
      placeholderLabel.font = font
    }

    if check.isDirty(\AutoResizingTextView.text) {
      placeholderLabel.isHidden = text.count > 0
    }

    if check.isDirty(\AutoResizingTextView.textContainerInset) {
      placeholderLabelConstraintX?.constant = textContainerInset.left + textContainer.lineFragmentPadding
      placeholderLabelConstraintY?.constant = textContainerInset.top
    }

    if check.isDirty(\AutoResizingTextView.placeholder) {
      placeholderLabel.text = placeholder
    }

    if check.isDirty(\AutoResizingTextView.placeholderAlpha) {
      placeholderLabel.alpha = placeholderAlpha
    }

    if check.isDirty(\AutoResizingTextView.placeholderTextColor, \AutoResizingTextView.textColor) {
      placeholderLabel.textColor = placeholderTextColor ?? textColor
    }
  }
}
