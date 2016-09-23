//
//  AXCountingLabel.h
//  AXCountingLabel
//
//  Created by devedbox on 16/8/16.
//  Copyright © 2016年 devedbox. All rights reserved.
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in all
//  copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
//  SOFTWARE.

#import <UIKit/UIKit.h>
NS_ASSUME_NONNULL_BEGIN
/// Format of counting label.
/// Decide the displaying text of counting time.
///
typedef NS_ENUM(NSInteger, AXCountingLabelCountingFormat) {
    /// Full format with hours like:
    ///
    /// dd:HH:mm:ss:SSS
    AXCountingLabelCountingFullFormat,
    /// Hour format like:
    ///
    /// HH:mm:ss:SSS
    AXCountingLabelCountingHourFormat,
    /// Minute format like:
    ///
    /// mm:ss:SSS
    AXCountingLabelCountingMinFormat,
    /// Second format like:
    ///
    /// ss:SSS
    AXCountingLabelCountingSecFormat,
    /// Millisecond format like:
    ///
    /// SSS
    AXCountingLabelCountingMsecFormat
};
/// Sub format of counting label.
///
typedef NS_ENUM(NSInteger, AXCountingLabelCountingSubformat) {
    /// Percent fromat.
    AXCountingLabelCountingPercentFormat,
    /// Millesimal format.
    AXCountingLabelCountingMillesimalFormat
};

@class AXCountingLabel;
@protocol AXCountingLabelDelegate <NSObject>
@optional
///
- (void)countingLabelDidReachThreshold:(AXCountingLabel *)label;
@end

@interface AXCountingLabel : UILabel
{
    @protected
    NSTimeInterval _remaining;
}
/// Delegate.
@property(assign, nonatomic) id<AXCountingLabelDelegate> delegate;
/// Format of counting.
@property(readonly, nonatomic) AXCountingLabelCountingFormat countingFormat;
/// Sub format of counting. Default is Percent.
@property(assign, nonatomic) AXCountingLabelCountingSubformat countingSubformat;
/// Threshold of counting time interval to notify user.
/// @discussion Threshold is the value between the current and the end point. When the threshold is reached, the corresponding agent and callback are triggered, that you can deal with.
///
/// @default Default is -1. When the value of threshold is less than 0.0, threshold does not effect. Otherwise, it does.
@property(assign, nonatomic) NSTimeInterval threshold;
/// Time interval.
@property(readonly, nonatomic) NSTimeInterval timeInterval;
/// Remaining counted time of label.
@property(readonly, nonatomic) NSTimeInterval remaining;
/// Is paused.
@property(readonly, nonatomic, getter=isPaused) BOOL isPaused;
/// Start counting with a time interval in future.
/// @discussion The time interval must be the tiem in future. If the time interval is in past, counting will not work.
///
/// @param time the time interval of counting since 1970.
/// @param completion a block call back when counting finished.
///
- (void)startCountingWithTime:(NSTimeInterval)time completion:(dispatch_block_t _Nullable)completion;
/// Pause counting.
///
- (void)pauseCounting;
/// Continue counting.
///
- (void)continueCounting;
/// Restart counting.
///
- (void)restartCounting;
/// Stop counting.
///
- (void)stopCounting;
#pragma mark - Subclasses
/// Get the from value for animation.
///
- (NSNumber *)reachableFromValue;
/// Get the to value for animation.
/// 
- (NSNumber *)reachableToValue;
/// Updating remaining time interval.
///
- (void)updateRemainingWithInterval:(NSTimeInterval)interval;
@end

@interface AXCountingLabel (Unavailable)
#pragma mark - Unavailable Methods
- (void)setText:(NSString *)text __attribute__((unavailable("AXCountingLabel cannot set text directly for current version")));
@end
NS_ASSUME_NONNULL_END
