import UIKit

final class HapticManager {
    static let shared = HapticManager()

    private init() {}

    // Check if device supports haptics
    var isHapticsAvailable: Bool {
        return UIDevice.current.userInterfaceIdiom == .phone
    }

    // MARK: - Convenience Methods

    /// Light impact feedback for general interactions
    func impact() {
        impact(style: .medium)
    }

    /// Success notification feedback
    func success() {
        notification(type: .success)
    }

    /// Warning notification feedback
    func warning() {
        notification(type: .warning)
    }

    /// Error notification feedback
    func error() {
        notification(type: .error)
    }

    // MARK: - Core Methods

    /// Impact haptic feedback with custom style
    func impact(style: UIImpactFeedbackGenerator.FeedbackStyle) {
        guard isHapticsAvailable else { return }
        let generator = UIImpactFeedbackGenerator(style: style)
        generator.prepare()
        generator.impactOccurred()
    }

    /// Notification haptic feedback with custom type
    func notification(type: UINotificationFeedbackGenerator.FeedbackType) {
        guard isHapticsAvailable else { return }
        let generator = UINotificationFeedbackGenerator()
        generator.prepare()
        generator.notificationOccurred(type)
    }

    /// Selection haptic feedback
    func selection() {
        guard isHapticsAvailable else { return }
        let generator = UISelectionFeedbackGenerator()
        generator.prepare()
        generator.selectionChanged()
    }
}
