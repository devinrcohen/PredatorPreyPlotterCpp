//
//  LVBridge.m
//  PredatorPreyPlotter
//
//  Created by Devin R Cohen on 11/23/25.
//

// Objective-C++ header for declaration of LVBridge
#import "LVBridge.h"
// the actual C++ header containing the declaration of LVResultVectors and lv_solve(...)
#import "lv_core.hpp"

@implementation LVBridge

+(NSDictionary<NSString *, NSArray<NSNumber *> *> *) solveWithAlpha:(double)alpha beta:(double)beta gamma:(double)gamma delta:(double)delta x0:(double)x0 y0:(double)y0 dt:(double)dt steps:(int)steps
{
    // this is our Obj-C++ source file actually calling a C++ function!
    LVResultVectors result = lv_solve(alpha, beta, gamma, delta, x0, y0, dt, steps);
    
    // Mutable Obj-C++ arrays which hold the data that will be returned to Swift. Each element boxed as an NSNumber
    NSMutableArray<NSNumber *> *tArr    = [NSMutableArray arrayWithCapacity:result.t.size()];
    NSMutableArray<NSNumber *> *preyArr = [NSMutableArray arrayWithCapacity:result.prey.size()];
    NSMutableArray<NSNumber *> *predArr = [NSMutableArray arrayWithCapacity:result.predator.size()];
    
    // Copy raw doubles from C++ vectors into NSArray tArr, preyArr, and predArr declared above
    for(size_t i = 0; i < result.t.size(); ++i)
    {
        // add time, prey, and predator to their respective NSMutableArray
        [tArr addObject:@(result.t[i])];
        [preyArr addObject:@(result.prey[i])];
        [predArr addObject:@(result.predator[i])];
    }
    
    // Package the three arrays into a single NSDictionary keyed by strings (see return type NSDictionary)
    // Swift will read these as [String: [NSNumber]]
    return @{
        @"t": tArr,
        @"prey": preyArr,
        @"predator": predArr
    };
}

@end
