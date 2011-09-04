//
//  TattleTale.m
//  Juggle
//
//  Created by Dave Hendrix on 9/3/11.
//  Copyright (c) 2011 Sog.gy. All rights reserved.
//

#import "TattleTale.h"
#import "AsyncUdpSocket.h"

@implementation TattleTale

-(TattleTale *)initWithHand:(NSString *)hand forServer:(NSString *)serverName
{
    self = [super init];
    if (self != nil) {
        whichHand = [hand retain];
        serverAddress = [serverName retain];
        accelerometer = [[UIAccelerometer sharedAccelerometer] retain];
        accelerometer.updateInterval = 1.0/30.0;
        accelerometer.delegate = self;
    }
    return self;
}

- (void)accelerometer:(UIAccelerometer *)accelerometer didAccelerate:(UIAcceleration *)acceleration
{
    AsyncUdpSocket *socket = [[AsyncUdpSocket alloc] init];
    NSString *jsonData = @"{\n";
    jsonData = [NSString stringWithFormat:@"%@%@", jsonData, @"    \"type\":\"sensor\",\n"];
    jsonData = [NSString stringWithFormat:@"%@%@", jsonData, @"    \"sensor_data\":\n"];
    jsonData = [NSString stringWithFormat:@"%@    {%c", jsonData, '\n'];
    jsonData = [NSString stringWithFormat:@"%@        \"hand\":\"%@\",\n", jsonData, whichHand];
    jsonData = [NSString stringWithFormat:@"%@        \"x\":\"%4.2f\",\n", jsonData, acceleration.x];
    jsonData = [NSString stringWithFormat:@"%@        \"y\":\"%4.2f\",\n", jsonData, acceleration.y];
    jsonData = [NSString stringWithFormat:@"%@        \"z\":\"%4.2f\"\n", jsonData, acceleration.z];
    jsonData = [NSString stringWithFormat:@"%@    }\n}\n", jsonData];

    NSLog(@"jsonData:\n%@", jsonData);
    NSData *data = [jsonData dataUsingEncoding:NSASCIIStringEncoding allowLossyConversion:YES];
    NSLog(@"send returned:%d", [socket sendData:data toHost:serverAddress port:12345 withTimeout:-1 tag:1]);

}

- (void)cancel
{
    if (accelerometer != nil)
        accelerometer.delegate = nil;
}

- (void)dealloc
{
    accelerometer.delegate = nil;
    [accelerometer release];
    [whichHand release];
    [serverAddress release];
    [super dealloc];
}

@end
