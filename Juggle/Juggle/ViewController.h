//
//  ViewController.h
//  Juggle
//
//  Created by Dave Hendrix on 9/3/11.
//  Copyright (c) 2011 RogueMinds.net. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AsyncUdpSocket.h"
#import "TattleTale.h"

@interface ViewController : UIViewController <UITextFieldDelegate>
{
    TattleTale *talker;
    BOOL useBluetooth;
}

@property (retain, nonatomic) IBOutlet UISegmentedControl *connectionMethodSwitch;
@property (retain, nonatomic) IBOutlet UILabel *serverLabel;
@property (retain, nonatomic) IBOutlet UITextField *serverAddress;
@property (retain, nonatomic) IBOutlet UILabel *connectMessage;
@property (retain, nonatomic) IBOutlet UILabel *connectAsLabel;
@property (retain, nonatomic) IBOutlet UIButton *leftButton;
@property (retain, nonatomic) IBOutlet UIButton *cancelButton;
@property (retain, nonatomic) IBOutlet UIButton *rightButton;

- (IBAction)selectMethod:(id)sender;
- (IBAction)connect:(id)sender;
- (IBAction)stopSending:(id)sender;

@end
