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
#import <GameKit/GameKit.h>


@interface TattleTale : NSObject <UIAccelerometerDelegate, CLLocationManagerDelegate, GKPeerPickerControllerDelegate, GKSessionDelegate>
{
    NSString *whichHand;
    NSString *serverAddress;
    UIAccelerometer *accelerometer;
    GKSession *gameKitSession;
    NSString *gameKitPeerId;
    AsyncUdpSocket *socket;
    CLLocationManager *locationManager;
    CLHeadingComponentValue lastOrientationX;
    CLHeadingComponentValue lastOrientationY;
    CLHeadingComponentValue lastOrientationZ;
    UILabel *localDisplayText;
    UILabel *remoteDisplayText;
}

-(TattleTale *)initWithHand:(NSString *)hand forServer:(NSString *)serverName localDisplayField:(UILabel *)local remoteDisplayField:(UILabel *)remote;
-(TattleTale *)initForGameKitWithHand:(NSString *)hand localDisplayField:(UILabel *)local remoteDisplayField:(UILabel *)remote;

- (void)invalidateSession:(GKSession *)session;

-(void)cancel;

@end
