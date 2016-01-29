//
//  ViewController.swift
//  ImageCompare
//
//  Created by Simon Gladman on 29/01/2016.
//  Copyright © 2016 Simon Gladman. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    let sunflowerOne = UIImage(named: "AAAAAA.jpg")!
    let sunflowerTwo = UIImage(named: "BBBBBB.jpg")!
    
    let simon = UIImage(named: "simon.jpg")!
    
    let iterations = 25
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        comparisonOne()
        comparisonTwo()
        comparisonThree()
    }

    func comparisonOne()
    {
        let startTime = CFAbsoluteTimeGetCurrent()
        
        for _ in 0 ... iterations
        {
            let _ = sunflowerOne.fb_compareWithImage(sunflowerOne)
            let _ = sunflowerOne.fb_compareWithImage(sunflowerTwo)
            let _ = sunflowerOne.fb_compareWithImage(simon)
        }
        
        let endTime = (CFAbsoluteTimeGetCurrent() - startTime)
        print("fb_compareWithImage - execution time", endTime)
    }

    func comparisonTwo()
    {
        let startTime = CFAbsoluteTimeGetCurrent()
        
        for _ in 0 ... iterations
        {
            let _ = UIImageEqualToImage(sunflowerOne, sunflowerOne)
            let _ = UIImageEqualToImage(sunflowerOne, sunflowerTwo)
            let _ = UIImageEqualToImage(sunflowerOne, simon)
        }
        
        let endTime = (CFAbsoluteTimeGetCurrent() - startTime)
        print("UIImageEqualToImage - execution time", endTime)
    }

    func comparisonThree()
    {
        let startTime = CFAbsoluteTimeGetCurrent()
        
        let context = CIContext()
        
        for _ in 0 ... iterations
        {
            let _ = UIImageEqualToImage(sunflowerOne, sunflowerOne, ciContext: context)
            let _ = UIImageEqualToImage(sunflowerOne, sunflowerTwo, ciContext: context)
            let _ = UIImageEqualToImage(sunflowerOne, simon, ciContext: context)
        }
        
        let endTime = (CFAbsoluteTimeGetCurrent() - startTime)
        print("UIImageEqualToImage (2) - execution time", endTime)
    }
    
}

/// Simon's Core Image image compare function
func UIImageEqualToImage(image1: UIImage, _ image2: UIImage, ciContext: CIContext? = nil) -> Bool
{
    guard let
        ciImage1 = CIImage(image: image1),
        ciImage2 = CIImage(image: image2) where image1.size == image2.size else
    {
        return false
    }
    
    let ctx = ciContext ?? CIContext()
    
    let difference = ciImage1.imageByApplyingFilter("CIDifferenceBlendMode",
        withInputParameters: [kCIInputBackgroundImageKey: ciImage2])
        .imageByApplyingFilter("CIAreaMaximum",
            withInputParameters: [kCIInputExtentKey: CIVector(CGRect: ciImage1.extent)])
    
    let totalBytes = 4
    let bitmap = calloc(totalBytes, sizeof(UInt8))
    
    ctx.render(difference,
        toBitmap: bitmap,
        rowBytes: totalBytes,
        bounds: difference.extent,
        format: kCIFormatRGBA8,
        colorSpace: nil)
    
    let rgba = UnsafeBufferPointer<UInt8>(
        start: UnsafePointer<UInt8>(bitmap),
        count: totalBytes)
    
    return rgba[0] == 0 && rgba[1] == 0 && rgba[2] == 0
}

extension UIImage
{
    /// Image compare function
    /// Taken from https://github.com/facebook/ios-snapshot-test-case/blob/master/FBSnapshotTestCase/Categories/UIImage+Compare.m#L47
    func fb_compareWithImage(image: UIImage) -> Bool
    {
        guard CGSizeEqualToSize(self.size, image.size) else
        {
            return false
        }
        
        let referenceImageSize = CGSizeMake(CGFloat(CGImageGetWidth(self.CGImage)), CGFloat(CGImageGetHeight(self.CGImage)))
        
        let imageSize = CGSizeMake(CGFloat(CGImageGetWidth(image.CGImage)), CGFloat(CGImageGetHeight(image.CGImage)))
        
        let minBytesPerRow = min(CGImageGetBytesPerRow(self.CGImage), CGImageGetBytesPerRow(image.CGImage))
        
        let referenceImageSizeBytes = Int(referenceImageSize.height) * minBytesPerRow
        
        let referenceImagePixels = calloc(1, referenceImageSizeBytes)
        
        let imagePixels = calloc(1, referenceImageSizeBytes)
        
        let referenceImageCtx = CGBitmapContextCreate(referenceImagePixels,
            Int(referenceImageSize.width),
            Int(referenceImageSize.height),
            CGImageGetBitsPerComponent(self.CGImage),
            minBytesPerRow,
            CGImageGetColorSpace(self.CGImage),
            CGImageAlphaInfo.PremultipliedLast.rawValue
        )
        
        let imageCtx = CGBitmapContextCreate(imagePixels,
            Int(imageSize.width),
            Int(imageSize.height),
            CGImageGetBitsPerComponent(image.CGImage),
            minBytesPerRow,
            CGImageGetColorSpace(image.CGImage),
            CGImageAlphaInfo.PremultipliedLast.rawValue
        )
        
        guard let referenceImageContext = referenceImageCtx, imageContext = imageCtx else
        {
            return false
        }
        
        CGContextDrawImage(referenceImageContext, CGRectMake(0, 0, referenceImageSize.width, referenceImageSize.height), self.CGImage);
        CGContextDrawImage(imageContext, CGRectMake(0, 0, imageSize.width, imageSize.height), image.CGImage);

        
        return (memcmp(referenceImagePixels, imagePixels, referenceImageSizeBytes) == 0)
    }
}

