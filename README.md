# ImageCompareDemo
Measures performance of two approaches to comparing the content of UIImage

Small experiment to look at the performance of two different approaches to comparing the contents of `UIImage` instances.

My initial technique was to use CoreImage. My first step was to apply a difference blend to the two images and pass that output to `CIAreaMaximum`. If any of the red, green or blue channels of the final output were non-zero, that would indicate the images were different. 

However, following a suggestion from [Peter Steinberger](https://twitter.com/steipete), I ported [this code](https://github.com/facebook/ios-snapshot-test-case/blob/master/FBSnapshotTestCase/Categories/UIImage+Compare.m) to Swift to do a side by side comparision. 

My Core Image solution, even without recreating a new `CIContext` with each compare, is a whole load slower! Looking at three 640x640 images 25 times gives these total timings on my iPad Pro:

* `fb_compareWithImage` - execution time 0.156560003757477
* `UIImageEqualToImage` - execution time 3.25684899091721
* `UIImageEqualToImage` (2) - execution time 1.75236403942108

_`UIImageEqualToImage` (2)_ - uses a single `CIContext`.

So, if you want to compare the contents of two images, stick with `memcmp`!

