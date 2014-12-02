//
//  SPwebRTCManager.h
//  Novocaine
//
//  Created by Nathan on 2014/12/2.
//  Copyright (c) 2014年 Nathan Chang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AudioToolbox/AudioToolbox.h>

@interface SPwebRTCManager : NSObject

+ (SPwebRTCManager *)sharedManager;

- (void)prepareProcessing;
- (NSData *)analyzeReverseStreamBuffer:(NSData *)renderBuffer description:(AudioStreamBasicDescription *)recordFormat;
- (NSData *)processCaptureStreamBuffer:(NSData *)captureBuffer description:(AudioStreamBasicDescription *)playFormat;

@end
