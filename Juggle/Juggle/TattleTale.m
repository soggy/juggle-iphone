//
//  TattleTale.m
//  Juggle
//
//  Created by Dave Hendrix on 9/3/11.
//  Copyright (c) 2011 Sog.gy. All rights reserved.
//

#import "TattleTale.h"

@implementation TattleTale

-(TattleTale *)initWithHand:(NSString *)hand forServer:(NSString *)serverName
{
    self = [super init];
    if (self != nil) {
        whichHand = [hand retain];
        serverAddress = [serverName retain];
        accelerometer = [[UIAccelerometer sharedAccelerometer] retain];
        accelerometer.updateInterval = 1.0/20.0;
        accelerometer.delegate = self;
        socket = [[[AsyncUdpSocket alloc] init] retain];

        // setup the location manager
        locationManager = [[[CLLocationManager alloc] init] retain];
        
        // check if the hardware has a compass
        if ([CLLocationManager headingAvailable] == NO) {
            // No compass is available. This application cannot function without a compass, 
            // so a dialog will be displayed and no magnetic data will be measured.
            locationManager = nil;
            UIAlertView *noCompassAlert = [[UIAlertView alloc] initWithTitle:@"No Compass!" message:@"This device does not have the ability to measure magnetic fields." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [noCompassAlert show];
            [noCompassAlert release];
        } else {
            // heading service configuration
            locationManager.headingFilter = kCLHeadingFilterNone;
            
            // setup delegate callbacks
            locationManager.delegate = self;
            
            // start the compass
            [locationManager startUpdatingHeading];
        }
        
        lastOrientationX = lastOrientationY = lastOrientationZ = 0.0;
    }
    return self;
}

- (void)accelerometer:(UIAccelerometer *)accelerometer didAccelerate:(UIAcceleration *)acceleration
{
    NSString *jsonDataFormat = \
@"{\n\
    \"type\":\"sensor\",\n\
    \"sensor_data\":\n\
    {\n\
      \"hand\":\"%@\",\n\
      \"x\":\"%6.4f\",\n\
      \"y\":\"%6.4f\",\n\
      \"z\":\"%6.4f\",\n\
      \"azimuth\":\"%6.4f\",\n\
      \"pitch\":\"%6.4f\",\n\
      \"roll\":\"%6.4f\"\n\
    }\n\
}";

    NSString *jsonData = [NSString stringWithFormat:jsonDataFormat, whichHand, acceleration.x, acceleration.y, acceleration.z, lastOrientationX, lastOrientationY, lastOrientationZ];

    [socket sendData:[jsonData dataUsingEncoding:NSASCIIStringEncoding allowLossyConversion:YES] toHost:serverAddress port:12345 withTimeout:-1 tag:1];
}

- (void)cancel
{
    if (accelerometer != nil)
        accelerometer.delegate = nil;
}

// This delegate method is invoked when the location manager has heading data.
- (void)locationManager:(CLLocationManager *)manager didUpdateHeading:(CLHeading *)heading {
    // Update the labels with the raw x, y, and z values.
	lastOrientationX = heading.x;
    lastOrientationY = heading.y;
	lastOrientationZ = heading.z;
}

// This delegate method is invoked when the location managed encounters an error condition.
- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error {
    if ([error code] == kCLErrorDenied) {
        // This error indicates that the user has denied the application's request to use location services.
        [manager stopUpdatingHeading];
    } else if ([error code] == kCLErrorHeadingFailure) {
        // This error indicates that the heading could not be determined, most likely because of strong magnetic interference.
    }
}


- (void)dealloc
{
    accelerometer.delegate = nil;
    [accelerometer release];
    [whichHand release];
    [serverAddress release];
    [socket release];
    [locationManager stopUpdatingHeading];
    [locationManager release];
    [super dealloc];
}

@end
