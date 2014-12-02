//
//  SPwebRTCManager.m
//  Novocaine
//
//  Created by Nathan on 2014/12/2.
//  Copyright (c) 2014年 Nathan Chang. All rights reserved.
//

#ifdef __APPLE__
#include "TargetConditionals.h"
#endif

#import "SPwebRTCManager.h"

#import "audio_processing.h"
#import "module_common_types.h"

@interface SPwebRTCManager()
{
    webrtc::AudioProcessing* _apm;
}
@end

@implementation SPwebRTCManager

+ (SPwebRTCManager *)sharedManager {
    static SPwebRTCManager *sharedSPwebRTCManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedSPwebRTCManager = [[self alloc] init];
    });
    return sharedSPwebRTCManager;
}

- (id)init {
    if (self = [super init]) {
#if !(TARGET_IPHONE_SIMULATOR)
        _apm = webrtc::AudioProcessing::Create(0);
#endif
    }
    return self;
}

- (void)dealloc {
    // Should never be called, but just here for clarity really.
}

- (void)prepareProcessing
{
#if !(TARGET_IPHONE_SIMULATOR)
    int result = 0;
    result = _apm->Initialize();
    NSLog(@"result:Initialize: %d", result);
    
    //debug_web TODO:Need change to variable after exp
    result = _apm->set_sample_rate_hz(8000); // Super-wideband processing.
    NSLog(@"result:set_sample_rate_hz: %d", result);
    //debug_web TODO:Need change to variable after exp
    result = _apm->set_num_channels(1, 1);
    NSLog(@"result:set_num_channels: %d", result);
    //debug_web TODO:Need change to variable after exp
    result = _apm->set_num_reverse_channels(1);
    NSLog(@"result:set_num_reverse_channels: %d", result);
    result = _apm->echo_cancellation()->Enable(true);
    //result = _apm->echo_control_mobile()->Enable(true);
    NSLog(@"result:echo_cancellation: %d", result);
    result = _apm->noise_suppression()->Enable(true);
    NSLog(@"result:echo_cancellation: %d", result);
    result = _apm->voice_detection()->Enable(true);
    NSLog(@"result:voice_detection: %d", result);
#endif
}

- (NSData *)analyzeReverseStreamBuffer:(NSData *)renderBuffer description:(AudioStreamBasicDescription *)recordFormat
{
#if !(TARGET_IPHONE_SIMULATOR)
    webrtc::AudioFrame frame;
    
    int16_t *originByte =(int16_t*)[renderBuffer bytes];
    //NSLog(@"analyzeReverseStreamBuffer sizeof(int16_t) * length = %ld * (%ld * %ld)", sizeof(int16_t), recordFormat->mChannelsPerFrame, (unsigned long)[renderBuffer length]);
    
    NSMutableData *tmpData = [[NSMutableData alloc] init];
    while([tmpData length] < [renderBuffer length])
    {
        //debug_web TODO:Need change to variable after exp
        frame.UpdateFrame(-1,
                          0,
                          &originByte[[tmpData length]/sizeof(int16_t)],
                          80, // samples_per_channel
                          8000,  //sample_rate_hz
                          webrtc::AudioFrame::kNormalSpeech,
                          webrtc::AudioFrame::kVadUnknown,
                          1,//recordFormat->mChannelsPerFrame, //num_channels
                          0);
        int result = _apm->AnalyzeReverseStream(&frame);
        NSLog(@"result:analyzeReverseStreamBuffer:%d", result);
        
        [tmpData appendBytes:frame.data_ length:80*sizeof(int16_t)];
        if([tmpData length] + 80 >= [renderBuffer length])
        {
            [tmpData setLength:[renderBuffer length]];
            break;
            //[tmpData appendBytes:&originByte[[tmpData length]/sizeof(int16_t)] length:[renderBuffer length] - [tmpData length]];
        }
        //NSLog(@"tmpData bytes in hex: %@", [tmpData description]);
    }
    
    return tmpData;
#endif
    return nil;
}

- (NSData *)processCaptureStreamBuffer:(NSData *)captureBuffer description:(AudioStreamBasicDescription *)playFormat
{
#if !(TARGET_IPHONE_SIMULATOR)
    webrtc::AudioFrame frame;
    int16_t *originByte =(int16_t*)[captureBuffer bytes];
    //NSLog(@"processCaptureStreamBuffer sizeof(int16_t) * length = %ld * %ld * %ld", sizeof(int16_t), playFormat->mChannelsPerFrame, (unsigned long)[captureBuffer length]);
    
    NSMutableData *tmpData = [[NSMutableData alloc] init];
    //NSLog(@"captureBuffer bytes in hex: %@", [captureBuffer description]);
    
    
    while([tmpData length] < [captureBuffer length])
    {
        //debug_web TODO:Need change to variable after exp
        int result = _apm->set_stream_delay_ms(1);
        //NSLog(@"result:set_stream_delay_ms: %d", result);
        frame.UpdateFrame(-1,
                          0,
                          &originByte[[tmpData length]/sizeof(int16_t)],
                          80, // samples_per_channel
                          8000,  //sample_rate_hz
                          webrtc::AudioFrame::kNormalSpeech,
                          webrtc::AudioFrame::kVadUnknown,
                          1,//playFormat->mChannelsPerFrame, //num_channels
                          0);
        result = _apm->ProcessStream(&frame);
        
        NSLog(@"result:ProcessStream:%d", result);
        
        if(_apm->echo_cancellation()->stream_has_echo())
        {
            NSLog(@"stream_has_echo = true");
        }
        else
        {
            NSLog(@"stream_has_echo = false");
        }
        
        [tmpData appendBytes:frame.data_ length:80*sizeof(int16_t)];
        if([tmpData length] + 80 >= [captureBuffer length])
        {
            [tmpData setLength:[captureBuffer length]];
            break;
            [tmpData appendBytes:&originByte[[tmpData length]/sizeof(int16_t)] length:[captureBuffer length] - [tmpData length]];
        }
        //NSLog(@"tmpData bytes in hex: %@", [tmpData description]);
    }
    return tmpData;
#endif
    return nil;
}


@end
