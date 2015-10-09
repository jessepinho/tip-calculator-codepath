//
//  FloatTicker.m
//  TipTapp
//
//  Created by Jesse Pinho on 10/8/15.
//  Copyright © 2015 Jesse Pinho. All rights reserved.
//

#import "FloatTicker.h"

static float const TickTime = 0.25;
static float const FramesPerSecond = 30.0;

@interface FloatTicker ()

@property float startAmount;
@property float endAmount;
@property float currentAmount;
@property (strong, nonatomic) void (^onTick)(float);

@end


@implementation FloatTicker

- (id)initWithStartAmount:(float)startAmount endAmount:(float)endAmount onTick:(void (^)(float))onTick {
    if (self = [super init]) {
        self.startAmount = startAmount;
        self.endAmount = endAmount;
        self.currentAmount = startAmount;
        self.onTick = onTick;
        return self;
    } else {
        return nil;
    }
}

- (void)startTicking {
    [NSTimer scheduledTimerWithTimeInterval:(1/FramesPerSecond) target:self selector:@selector(tick:) userInfo:nil repeats:YES];
}

- (float)getTickInterval {
    return (self.endAmount - self.startAmount) / [self getNumberOfTicks];
}

- (float)getNumberOfTicks {
    return FramesPerSecond * TickTime;
}

- (BOOL)endAmountIsGreaterThanStartAmount {
    return self.endAmount > self.startAmount;
}

- (BOOL)doneTicking {
    if (([self endAmountIsGreaterThanStartAmount] && self.currentAmount >= self.endAmount)
        || (![self endAmountIsGreaterThanStartAmount] && self.currentAmount <= self.endAmount)) {
        return YES;
    }
    return NO;
}

- (void)tick:(NSTimer *)timer {
    self.currentAmount += [self getTickInterval];
    if ([self doneTicking]) {
        [timer invalidate];
        self.currentAmount = self.endAmount;
    }
    self.onTick(self.currentAmount);
}
@end