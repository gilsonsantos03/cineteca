import UIKit

// MARK: - Movie Review Rating Slider

final class MovieReviewRatingSlider: UISlider {
    // MARK: Layout

    override func trackRect(forBounds bounds: CGRect) -> CGRect {
        let horizontalInset = bounds.width / 22
        return CGRect(
            x: horizontalInset,
            y: bounds.midY - 2,
            width: bounds.width - (horizontalInset * 2),
            height: 4
        )
    }

    override func thumbRect(
        forBounds bounds: CGRect,
        trackRect rect: CGRect,
        value: Float
    ) -> CGRect {
        let defaultThumbRect = super.thumbRect(
            forBounds: bounds,
            trackRect: rect,
            value: value
        )
        let progress = CGFloat((value - minimumValue) / (maximumValue - minimumValue))
        let centerX = rect.minX + (rect.width * progress)
        return CGRect(
            x: centerX - (defaultThumbRect.width / 2),
            y: rect.midY - (defaultThumbRect.height / 2),
            width: defaultThumbRect.width,
            height: defaultThumbRect.height
        )
    }

    // MARK: Appearance

    static func makeThumbImage() -> UIImage {
        let size = CGSize(width: 22, height: 22)
        return UIGraphicsImageRenderer(size: size).image { context in
            let circleRect = CGRect(
                origin: CGPoint(x: 2, y: 2),
                size: CGSize(width: 18, height: 18)
            )
            UIColor.accentYellow.setFill()
            context.cgContext.fillEllipse(in: circleRect)
        }
    }
}
