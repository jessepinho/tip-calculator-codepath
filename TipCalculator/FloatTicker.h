//
//  FloatTicker.h
//  TipTapp
//
//  Created by Jesse Pinho on 10/8/15.
//  Copyright © 2015 Jesse Pinho. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FloatTicker : NSObject

- (id)initWithStartAmount:(float)startAmount endAmount:(float)endAmount onTick:(void (^)(float))onTick;
- (void)startTicking;

@end
