//
//  LVBridge.h
//  PredatorPreyPlotter
//
//  Created by Devin R Cohen on 11/23/25.
//
// This header is for the Bridge interface

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

// Bridge class
// Visible to Swift via the bridging header
// Implemented in Objective-C++ (LVBridge.mm)
@interface LVBridge : NSObject

/// Returns a dictionary with keys "t", "prey", "predator"
/// Public class method that runs the C++ solver.
/// Input: Pass in all LV parameters and initial conditions as doubles (except for steps)
/// Return: NSDictionary containing three NXNumber arrays: "t" -> [NSNumber] of time samples, "prey/predator" -> [NSNumber] of prey/pred values
/// Syntax NSDictionary
+ (NSDictionary<NSString *, NSArray<NSNumber *> *> *)solveWithAlpha:(double)alpha
                                                               beta:(double)beta
                                                              gamma:(double)gamma
                                                              delta:(double)delta
                                                                 x0:(double)x0
                                                                 y0:(double)y0
                                                                 dt:(double)dt
                                                              steps:(int)steps;

@end

NS_ASSUME_NONNULL_END
