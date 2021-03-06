#import "RCTConvert+WebRTC.h"
#import <WebRTC/RTCDataChannelConfiguration.h>
#import <WebRTC/RTCIceServer.h>
#import <WebRTC/RTCSessionDescription.h>

@implementation RCTConvert (WebRTC)

+ (RTCSessionDescription *)RTCSessionDescription:(id)json
{
  if (!json) {
    RCTLogConvertError(json, @"must not be null");
    return nil;
  }

  if (![json isKindOfClass:[NSDictionary class]]) {
    RCTLogConvertError(json, @"must be an object");
    return nil;
  }

  if (json[@"sdp"] == nil) {
    RCTLogConvertError(json, @".sdp must not be null");
    return nil;
  }

  NSString *sdp = json[@"sdp"];
  RTCSdpType sdpType = [RTCSessionDescription typeForString:json[@"type"]];

  return [[RTCSessionDescription alloc] initWithType:sdpType sdp:sdp];
}

+ (RTCIceCandidate *)RTCIceCandidate:(id)json
{
  if (!json) {
    RCTLogConvertError(json, @"must not be null");
    return nil;
  }

  if (![json isKindOfClass:[NSDictionary class]]) {
    RCTLogConvertError(json, @"must be an object");
    return nil;
  }

  if (json[@"candidate"] == nil) {
    RCTLogConvertError(json, @".candidate must not be null");
    return nil;
  }

  NSString *sdp = json[@"candidate"];
  NSLog(@"%@ <- candidate", sdp);
  int sdpMLineIndex = [RCTConvert int:json[@"sdpMLineIndex"]];
  NSString *sdpMid = json[@"sdpMid"];


  return [[RTCIceCandidate alloc] initWithSdp:sdp sdpMLineIndex:sdpMLineIndex sdpMid:sdpMid];
}

+ (RTCIceServer *)RTCIceServer:(id)json
{
  if (!json) {
    RCTLogConvertError(json, @"a valid iceServer value");
    return nil;
  }

  if (![json isKindOfClass:[NSDictionary class]]) {
    RCTLogConvertError(json, @"must be an object");
    return nil;
  }

  NSArray<NSString *> *urls;
  if ([json[@"url"] isKindOfClass:[NSString class]]) {
    // TODO: 'url' is non-standard
    urls = @[json[@"url"]];
  } else if ([json[@"urls"] isKindOfClass:[NSString class]]) {
    urls = @[json[@"urls"]];
  } else {
    urls = [RCTConvert NSArray:json[@"urls"]];
  }

  if (json[@"username"] != nil || json[@"credential"] != nil) {
    return [[RTCIceServer alloc]initWithURLStrings:urls
                                        username:json[@"username"]
                                        credential:json[@"credential"]];
  }

  return [[RTCIceServer alloc] initWithURLStrings:urls];
}

+ (RTCConfiguration *)RTCConfiguration:(id)json
{

  if (!json) {
    return nil;
  }

  if (![json isKindOfClass:[NSDictionary class]]) {
    RCTLogConvertError(json, @"must be an object");
    return nil;
  }

  RTCConfiguration *config = [[RTCConfiguration alloc] init];

  if (json[@"iceServers"] != nil && [json[@"iceServers"] isKindOfClass:[NSArray class]]) {
    NSMutableArray<RTCIceServer *> *iceServers = [NSMutableArray new];
    for (id server in json[@"iceServers"]) {
      RTCIceServer *convert = [RCTConvert RTCIceServer:server];
      if (convert != nil) {
        [iceServers addObject:convert];
      }
    }
    config.iceServers = iceServers;
  }

  // TODO: Implement the rest of the RTCConfigure options ...

  return config;
}

+ (RTCDataChannelConfiguration *)RTCDataChannelConfiguration:(id)json
{
  if (!json) {
    return nil;
  }
  if ([json isKindOfClass:[NSDictionary class]]) {
    RTCDataChannelConfiguration *init = [RTCDataChannelConfiguration new];

    if (json[@"id"]) {
      [init setChannelId:[RCTConvert int:json[@"id"]]];
    }

    if (json[@"ordered"]) {
      init.isOrdered = [RCTConvert BOOL:json[@"ordered"]];
    }
    if (json[@"maxRetransmitTime"]) {
      init.maxRetransmitTimeMs = [RCTConvert NSInteger:json[@"maxRetransmitTime"]];
    }
    if (json[@"maxRetransmits"]) {
      init.maxRetransmits = [RCTConvert int:json[@"maxRetransmits"]];
    }
    if (json[@"negotiated"]) {
      init.isNegotiated = [RCTConvert NSInteger:json[@"negotiated"]];
    }
    if (json[@"protocol"]) {
      init.protocol = [RCTConvert NSString:json[@"protocol"]];
    }
    return init;
  }
  return nil;
}

@end
