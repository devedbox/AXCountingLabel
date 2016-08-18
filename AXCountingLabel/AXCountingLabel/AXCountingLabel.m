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
#import <AXCGPathFromString/UIBezierPath+TextPaths.h>

@interface AXCountingLabel ()
{
    AXCountingLabelCountingFormat _format;
    UIColor *_textColor;
}
/// Display link.
@property(strong, nonatomic) CADisplayLink *display;
/// Time interval.
@property(assign, nonatomic) NSTimeInterval timeInterval;
/// Counting time interval.
@property(assign, nonatomic) NSTimeInterval countingTimeInterval;
/// Counting time.
@property(assign, nonatomic) NSInteger countingTime;
/// Completion block.
@property(copy, nonatomic) dispatch_block_t completion;
/// Gradient layer.
@property(strong, nonatomic) CAGradientLayer *gradientLayer;
/// Shape layer.
@property(strong, nonatomic) CAShapeLayer *shapeLayer;
@end

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
    _countingTimeInterval = 99.0;
    _countingTime = 60;
    _gradientEnabled = YES;
    _gradientColor = [UIColor orangeColor];
    _gradientEndColor = [UIColor redColor];
    
    [self.layer addSublayer:self.gradientLayer];
    _gradientLayer.mask = self.shapeLayer;
    [self updateTextPath];
}

#pragma mark - Override
- (void)layoutSublayersOfLayer:(CALayer *)layer {
    [super layoutSublayersOfLayer:layer];
    
    _gradientLayer.frame = self.layer.bounds;
    
    [self updateTextPath];
}
#pragma mark - Getters
- (CADisplayLink *)display {
    if (_display) return _display;
    _display = [CADisplayLink displayLinkWithTarget:self selector:@selector(displayHandler:)];
    return _display;
}

- (NSTimeInterval)remaining {
    return _timeInterval;
}

- (AXCountingLabelCountingFormat)countingFormat {
    return _format;
}

- (CAGradientLayer *)gradientLayer {
    if (_gradientLayer) return _gradientLayer;
    _gradientLayer = [CAGradientLayer layer];
    _gradientLayer.startPoint = CGPointMake(.0, .5);
    _gradientLayer.endPoint = CGPointMake(1.0, .5);
    _gradientLayer.colors = @[(id)_gradientColor.CGColor, (id)_gradientEndColor.CGColor];
    return _gradientLayer;
}

- (CAShapeLayer *)shapeLayer {
    if (_shapeLayer) return _shapeLayer;
    _shapeLayer = [CAShapeLayer layer];
    return _shapeLayer;
}

#pragma mark - Setters

- (void)setGradientColor:(UIColor *)gradientColor {
    _gradientColor = gradientColor;
    [self setStrokeColors];
}

- (void)setGradientEndColor:(UIColor *)gradientEndColor {
    _gradientEndColor = gradientEndColor;
    [self setStrokeColors];
}

- (void)setGradientEnabled:(BOOL)gradientEnabled {
    _gradientEnabled = gradientEnabled;
    [self updateTextPath];
}

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
    // Start display link.
    [self startDisplayLink];
    // Set text content.
    //
    
    [self setTextWithTimeInterval:_countingTimeInterval];
}

- (void)pauseCounting {
    [self pauseDisplayLink];
}

- (void)restartCounting {
    [self restartDisplayLink];
}

- (void)stopCounting {
    [self stopDisplayLink];
}

#pragma mark - Private
- (void)startDisplayLink {
    if (_display || _display.paused) {
        [self stopDisplayLink];
    }
    [self.display addToRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
    
    _countingTime = 60;
    switch (_countingSubformat) {
        case AXCountingLabelCountingMillesimalFormat:
            _countingTimeInterval = 999.0;
            break;
        default:
            _countingTimeInterval = 99.0;
            break;
    }
}

- (void)pauseDisplayLink {
    if (self.display.paused) {
        return;
    }
    [self.display setPaused:YES];
}

- (void)restartDisplayLink {
    if (!self.display.paused) {
        return;
    }
    [self.display setPaused:NO];
}

- (void)stopDisplayLink {
    if (!_display) {
        return;
    }
    [self.display invalidate];
    _display = nil;
}

- (void)displayHandler:(CADisplayLink *)sender {
    // Reduce the counting time.
    switch (_countingSubformat) {
        case AXCountingLabelCountingMillesimalFormat:
            _countingTimeInterval-=16.5;
            break;
        default:
            _countingTimeInterval-=1.65;
            break;
    }
    _countingTime--;
    if (_countingTimeInterval <= 0 || _countingTime < 0) {
        _timeInterval--;
        switch (_countingSubformat) {
            case AXCountingLabelCountingMillesimalFormat:
                _countingTimeInterval = 999.0;
                break;
            default:
                _countingTimeInterval = 99.0;
                break;
        }
        _countingTime = 60;
    }
    
    if (_timeInterval <= _threshold) {
        if (_delegate && [_delegate respondsToSelector:@selector(countingLabelDidReachThreshold:)]) {
            [_delegate countingLabelDidReachThreshold:self];
        }
    }
    
    if (_timeInterval <= 0) {
        _timeInterval = 0.0;
        _countingTimeInterval = 0.0;
        [self stopDisplayLink];
        if (_completion) {
            _completion();
        }
    }
    
    [self setTextWithTimeInterval:_countingTimeInterval];
}

- (void)setTextWithTimeInterval:(NSTimeInterval)timeInterval {
    // Get minutes of time interval.
    NSInteger minutes = _timeInterval / 60.0;
    // Get hours of time interval.
    NSInteger hours = _timeInterval / 3600.0;
    // Get days of time interval.
    NSInteger days = hours / 24;
    
    // Set fromat.
    AXCountingLabelCountingFormat format;
    
    if (_timeInterval < 60) {
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
            super.text = [NSString stringWithFormat:@"%ld", (long)(((long)_timeInterval)*1000+timeInterval)];
            break;
        case AXCountingLabelCountingSecFormat:
            switch (_countingSubformat) {
                case AXCountingLabelCountingMillesimalFormat:
                    super.text = [NSString stringWithFormat:@"%.2ld:%.3ld", (long)_timeInterval, (long)timeInterval];
                    break;
                default:
                    super.text = [NSString stringWithFormat:@"%.2ld:%.2ld", (long)_timeInterval, (long)timeInterval];
                    break;
            }
            break;
        case AXCountingLabelCountingMinFormat:
            switch (_countingSubformat) {
                case AXCountingLabelCountingMillesimalFormat:
                    super.text = [NSString stringWithFormat:@"%.2ld:%.2ld:%.3ld", minutes, ((long)_timeInterval % 60), (long)timeInterval];
                    break;
                default:
                    super.text = [NSString stringWithFormat:@"%.2ld:%.2ld:%.2ld", minutes, ((long)_timeInterval % 60), (long)timeInterval];
                    break;
            }
            break;
        case AXCountingLabelCountingHourFormat:
            switch (_countingSubformat) {
                case AXCountingLabelCountingMillesimalFormat:
                    super.text = [NSString stringWithFormat:@"%.2ld:%.2ld:%.2ld:%.3ld", hours, minutes % 60, ((long)_timeInterval % 60), (long)timeInterval];
                    break;
                default:
                    super.text = [NSString stringWithFormat:@"%.2ld:%.2ld:%.2ld:%.2ld", hours, minutes % 60, ((long)_timeInterval % 60), (long)timeInterval];
                    break;
            }
            break;
        default:
            switch (_countingSubformat) {
                case AXCountingLabelCountingMillesimalFormat:
                    super.text = [NSString stringWithFormat:@"%ld:%.2ld:%.2ld:%.2ld:%.3ld", days, hours%24, minutes % 60, ((long)_timeInterval % 60), (long)timeInterval];
                    break;
                default:
                    super.text = [NSString stringWithFormat:@"%ld:%.2ld:%.2ld:%.2ld:%.2ld", days, hours%24, minutes % 60, ((long)_timeInterval % 60), (long)timeInterval];
                    break;
            }
            break;
    }
    // Update text path.
    [self updateTextPath];
}

- (void)setStrokeColors {
    NSMutableArray *colors = [NSMutableArray array];
    if (_gradientColor != nil) {
        [colors addObject:(id)_gradientColor.CGColor];
    }
    if (_gradientEndColor != nil) {
        [colors addObject:(id)_gradientEndColor.CGColor];
    }
    _gradientLayer.colors = colors;
}

- (void)updateTextPath {
    if (_gradientEnabled) {
        [self.layer addSublayer:_gradientLayer];
        _gradientLayer.mask = _shapeLayer;
        // Set path of text.
        CGPathRef path = [UIBezierPath bezierPathForString:self.text withFont:self.font].CGPath;
        _shapeLayer.path = path;
        CGRect pathBounds = CGPathGetBoundingBox(path);
        _shapeLayer.frame = CGRectMake(0, (long)(CGRectGetHeight(self.bounds)*.5 - ceil(CGRectGetHeight(pathBounds))*.5), CGRectGetWidth(self.frame), ceil(CGRectGetHeight(pathBounds)));
        
        // Set text color to clear color if needed.
        if (![super.textColor isEqual:[UIColor clearColor]]) {
            super.textColor = [UIColor clearColor];
        }
    } else {
        _gradientLayer.mask = nil;
        [_gradientLayer removeFromSuperlayer];
        super.textColor = _textColor;
    }
}
@end