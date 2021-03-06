//
//  AXCountingDownLabel.m
//  AXCountingLabel
//
//  Created by devedbox on 2016/9/23.
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

#import "AXCountingDownLabel.h"

static NSString *const kAXCountingDownLabelDefaultPlaceholder = @"00:00";

@implementation AXCountingDownLabel

- (NSNumber *)reachableFromValue {
    if (self.isPaused) {
        return @(self.remaining);
    } else if (self.remaining != 0) {
        return @(self.remaining);
    } else {
        return @(self.timeInterval);
    }
}

- (NSNumber *)reachableToValue {
    return @(0.0);
}

- (void)startCountingWithTime:(NSTimeInterval)time completion:(dispatch_block_t)completion {
    // Get the time interval of now.
    NSTimeInterval now = [[NSDate date] timeIntervalSince1970];
    // Handle the time.
    if (time <= now) {
        // Date the time refrenced is in past. Do nothing. Show palcehodler to take place.
        [self setValue:_placeholder?:kAXCountingDownLabelDefaultPlaceholder forKeyPath:@"text"];
        return;
    } else {
        [super startCountingWithTime:time completion:completion];
    }
}

- (void)updateRemainingWithInterval:(NSTimeInterval)interval {
    _remaining = interval;
    
    if (_remaining <= self.threshold) {
        if (self.delegate && [self.delegate respondsToSelector:@selector(countingLabelDidReachThreshold:)]) {
            [self.delegate countingLabelDidReachThreshold:self];
        }
    }
}

- (void)countingDidFinish {
    [super countingDidFinish];
    
    // The counting down is finished. Do nothing. Show palcehodler to take place.
    [self setValue:_placeholder?:kAXCountingDownLabelDefaultPlaceholder forKeyPath:@"text"];
}
@end
