//
//  TattleTale.h
//  Juggle
//
//  Created by Dave Hendrix on 9/3/11.
//  Copyright (c) 2011 Sog.gy. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TattleTale : NSObject <UIAccelerometerDelegate>
{
    NSString *whichHand;
    NSString *serverAddress;
    UIAccelerometer *accelerometer;
}

-(TattleTale *)initWithHand:(NSString *)hand forServer:(NSString *)serverName;
-(void)cancel;

@end
