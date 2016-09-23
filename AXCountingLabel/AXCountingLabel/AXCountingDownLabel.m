//
//  AXCountingDownLabel.m
//  AXCountingLabel
//
//  Created by devedbox on 2016/9/23.
//  Copyright © 2016年 devedbox. All rights reserved.
//

#import "AXCountingDownLabel.h"

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

- (void)updateRemainingWithInterval:(NSTimeInterval)interval {
    _remaining = interval;
    
    if (_remaining <= self.threshold) {
        if (self.delegate && [self.delegate respondsToSelector:@selector(countingLabelDidReachThreshold:)]) {
            [self.delegate countingLabelDidReachThreshold:self];
        }
    }
}
@end
