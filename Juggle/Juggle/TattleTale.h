//
//  TattleTale.h
//  Juggle
//
//  Created by Dave Hendrix on 9/3/11.
//  Copyright (c) 2011 Sog.gy. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>
#import "AsyncUdpSocket.h"


@interface TattleTale : NSObject <UIAccelerometerDelegate, CLLocationManagerDelegate>
{
    NSString *whichHand;
    NSString *serverAddress;
    UIAccelerometer *accelerometer;
    AsyncUdpSocket *socket;
    CLLocationManager *locationManager;
    CLHeadingComponentValue lastOrientationX;
    CLHeadingComponentValue lastOrientationY;
    CLHeadingComponentValue lastOrientationZ;
}

-(TattleTale *)initWithHand:(NSString *)hand forServer:(NSString *)serverName;
-(void)cancel;

@end
