//
//  AXCountingUpLabel.m
//  AXCountingLabel
//
//  Created by devedbox on 2016/9/23.
//  Copyright © 2016年 devedbox. All rights reserved.
//

#import "AXCountingUpLabel.h"

@implementation AXCountingUpLabel

- (NSNumber *)reachableFromValue {
    return @(self.remaining==0?self.remaining:self.timeInterval-self.remaining);
}

- (NSNumber *)reachableToValue {
    return @(self.timeInterval);
}

- (void)updateRemainingWithInterval:(NSTimeInterval)interval {
    _remaining = self.timeInterval - interval;
    
    if (_remaining <= self.threshold) {
        if (self.delegate && [self.delegate respondsToSelector:@selector(countingLabelDidReachThreshold:)]) {
            [self.delegate countingLabelDidReachThreshold:self];
        }
    }
}
@end
