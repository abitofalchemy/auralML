//
//  ViewController.h
//  blscanner
//
//  Created by Sal Aguinaga on 3/12/17.
//  Copyright © 2017 Sal Aguinaga. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreBluetooth/CoreBluetooth.h>

@interface ViewController : UIViewController <CBCentralManagerDelegate>

@property (nonatomic, strong) CBCentralManager *centralManager;

@end

