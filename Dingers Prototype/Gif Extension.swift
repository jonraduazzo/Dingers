//
//  Gif Extension.swift
//  Dingers Prototype
//
//  Created by Jon Raduazzo on 3/7/25.
//

import Foundation
import UIKit
import ImageIO

extension UIImage {
    static func gif(data: Data) -> UIImage? {
        guard let source = CGImageSourceCreateWithData(data as CFData, nil) else { return nil }
        return UIImage.animatedImage(with: getFrames(source: source), duration: getDuration(source: source))
    }

    private static func getFrames(source: CGImageSource) -> [UIImage] {
        let count = CGImageSourceGetCount(source)
        var images: [UIImage] = []

        for i in 0..<count {
            if let cgImage = CGImageSourceCreateImageAtIndex(source, i, nil) {
                images.append(UIImage(cgImage: cgImage))
            }
        }

        return images
    }

    private static func getDuration(source: CGImageSource) -> TimeInterval {
        let count = CGImageSourceGetCount(source)
        var duration: TimeInterval = 0

        for i in 0..<count {
            let frameDuration = getFrameDuration(source: source, index: i)
            duration += frameDuration
        }

        return duration
    }

    private static func getFrameDuration(source: CGImageSource, index: Int) -> TimeInterval {
        guard let properties = CGImageSourceCopyPropertiesAtIndex(source, index, nil) as? [CFString: Any],
              let gifProperties = properties[kCGImagePropertyGIFDictionary] as? [CFString: Any],
              let unclampedDelayTime = gifProperties[kCGImagePropertyGIFUnclampedDelayTime] as? TimeInterval else {
            return 0.1
        }

        return unclampedDelayTime > 0 ? unclampedDelayTime : 0.1
    }
}
