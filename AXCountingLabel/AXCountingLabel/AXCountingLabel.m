//
//  AXCountingLabel.m
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

#import "AXCountingLabel.h"
#import <pop/POP.h>

@interface AXCountingLabel ()
{
    AXCountingLabelCountingFormat _format;
    UIColor *_textColor;
    
    NSTimeInterval _timeInterval;
    
    BOOL _isPaused;
}
/// Text updating animatable property.
@property(strong, nonatomic) POPAnimatableProperty *textUpdatingProperty;
/// Text updating animation.
@property(strong, nonatomic) POPBasicAnimation *textUpdatingAnimation;
/// Completion block.
@property(copy, nonatomic) dispatch_block_t completion;
@end

static NSString *const kAXCountingAnimationKey = @"counting";

@implementation AXCountingLabel
#pragma mark - Initializer
- (instancetype)init {
    if (self = [super init]) {
        [self initializer];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super initWithCoder:aDecoder]) {
        [self initializer];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self initializer];
    }
    return self;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    // Set up initializer.
    [self initializer];
}

- (void)initializer {
    _countingSubformat = AXCountingLabelCountingPercentFormat;
    _threshold = -1.0;
}

#pragma mark - Override
- (void)dealloc {
    [self stopCounting];
}
#pragma mark - Getters
- (POPAnimatableProperty *)textUpdatingProperty {
    if (_textUpdatingProperty) return _textUpdatingProperty;
    POPAnimatableProperty *property = [POPAnimatableProperty propertyWithName:kAXCountingAnimationKey initializer:^(POPMutableAnimatableProperty *prop) {
        // write value
        prop.writeBlock = ^(AXCountingLabel *label, const CGFloat values[]) {
            [label setTextWithTimeInterval:values[0]];
        };
    }];
    _textUpdatingProperty = property;
    return property;
}

- (POPBasicAnimation *)textUpdatingAnimation {
    if (_textUpdatingAnimation) return _textUpdatingAnimation;
    _textUpdatingAnimation = [POPBasicAnimation linearAnimation];
    _textUpdatingAnimation.property = self.textUpdatingProperty;
    return _textUpdatingAnimation;
}

- (NSTimeInterval)remaining {
    return _remaining;
}

- (AXCountingLabelCountingFormat)countingFormat {
    return _format;
}

#pragma mark - Setters
- (void)setTextColor:(UIColor *)textColor {
    _textColor = textColor;
    [super setTextColor:textColor];
}

#pragma mark - Public
- (void)startCountingWithTime:(NSTimeInterval)time completion:(dispatch_block_t)completion {
    _completion = [completion copy];
    // Get the time interval of now.
    NSTimeInterval now = [[NSDate date] timeIntervalSince1970];
    // Handle the time.
    if (time <= now) {
        // Date the time refrenced is in past. Do nothing.
        return;
    }
    // Do work.
    //
    _timeInterval = time - now;

    self.textUpdatingAnimation.fromValue = [self reachableFromValue];
    _textUpdatingAnimation.toValue = [self reachableToValue];
    _textUpdatingAnimation.duration = _timeInterval;
    __weak typeof(self) wself = self;
    _textUpdatingAnimation.completionBlock = ^(POPAnimation *ani, BOOL finished) {
        if (finished) {
            if (wself.completion) {
                wself.completion();
            }
        }
    };
    
    [self pop_removeAnimationForKey:kAXCountingAnimationKey];
    [self pop_addAnimation:_textUpdatingAnimation forKey:kAXCountingAnimationKey];
}

- (void)pauseCounting {
    _isPaused = YES;
    [self pop_removeAnimationForKey:kAXCountingAnimationKey];
}

- (void)continueCounting {
    _isPaused = NO;
    _textUpdatingAnimation.fromValue = [self reachableFromValue];
    _textUpdatingAnimation.toValue = [self reachableToValue];
    _textUpdatingAnimation.duration = [self remaining];
    [self pop_addAnimation:_textUpdatingAnimation forKey:kAXCountingAnimationKey];
}

- (void)restartCounting {
    [self stopCounting];
    [self startCountingWithTime:_timeInterval completion:_completion];
}

- (void)stopCounting {
    [self pop_removeAnimationForKey:kAXCountingAnimationKey];
    _timeInterval = 0.0;
    _remaining = 0.0;
}

#pragma mark - Private

- (void)setTextWithTimeInterval:(NSTimeInterval)timeInterval {
    [self updateRemainingWithInterval:timeInterval];
    // Get the secs of time interval.
    NSInteger secs = (int)timeInterval % 60;
    // Get minutes of time interval.
    NSInteger minutes = timeInterval / 60;
    // Get hours of time interval.
    NSInteger hours = minutes / 60;
    // Get days of time interval.
    NSInteger days = hours / 24;
    
    // Set fromat.
    AXCountingLabelCountingFormat format;
    
    if (timeInterval < 60) {
        _format = AXCountingLabelCountingSecFormat;
    } else if (minutes < 60) {
        _format = AXCountingLabelCountingMinFormat;
    } else if (hours < 24) {
        _format = AXCountingLabelCountingHourFormat;
    } else {
        _format = AXCountingLabelCountingFullFormat;
    }
    format = _format;
    
    // Set text content.
    switch (format) {
        case AXCountingLabelCountingMsecFormat:
            super.text = [NSString stringWithFormat:@"%ld", (long)timeInterval];
            break;
        case AXCountingLabelCountingSecFormat:
            switch (_countingSubformat) {
                case AXCountingLabelCountingMillesimalFormat:
                    super.text = [NSString stringWithFormat:@"%.2ld:%.3ld", (long)secs, (long)(timeInterval*1000)%1000];
                    break;
                default:
                    super.text = [NSString stringWithFormat:@"%.2ld:%.2ld", (long)secs, (long)(timeInterval*100)%100];
                    break;
            }
            break;
        case AXCountingLabelCountingMinFormat:
            switch (_countingSubformat) {
                case AXCountingLabelCountingMillesimalFormat:
                    super.text = [NSString stringWithFormat:@"%.2ld:%.2ld:%.3ld", minutes, secs, (long)(timeInterval*1000)%1000];
                    break;
                default:
                    super.text = [NSString stringWithFormat:@"%.2ld:%.2ld:%.2ld", minutes, secs, (long)(timeInterval*100)%100];
                    break;
            }
            break;
        case AXCountingLabelCountingHourFormat:
            switch (_countingSubformat) {
                case AXCountingLabelCountingMillesimalFormat:
                    super.text = [NSString stringWithFormat:@"%.2ld:%.2ld:%.2ld:%.3ld", hours, minutes, secs, (long)(timeInterval*1000)%1000];
                    break;
                default:
                    super.text = [NSString stringWithFormat:@"%.2ld:%.2ld:%.2ld:%.2ld", hours, minutes, secs, (long)(timeInterval*100)%100];
                    break;
            }
            break;
        default:
            switch (_countingSubformat) {
                case AXCountingLabelCountingMillesimalFormat:
                    super.text = [NSString stringWithFormat:@"%ld:%.2ld:%.2ld:%.2ld:%.3ld", days, hours, minutes, secs, (long)(timeInterval*1000)%1000];
                    break;
                default:
                    super.text = [NSString stringWithFormat:@"%ld:%.2ld:%.2ld:%.2ld:%.2ld", days, hours, minutes, secs, (long)(timeInterval*100)%100];
                    break;
            }
            break;
    }
}

- (NSNumber *)reachableToValue {
    return @(0.0);
}

- (NSNumber *)reachableFromValue {
    return @(0.0);
}

- (void)updateRemainingWithInterval:(NSTimeInterval)interval {
    _remaining = interval;
}
@end
