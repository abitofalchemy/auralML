//
//  ViewController.m
//  blscanner
//
//  Created by Sal Aguinaga on 3/12/17.
//  Copyright © 2017 Sal Aguinaga. All rights reserved.
//
/* 
 https://alperkayabasi.com/tag/cbcentralmanager/
 */
#import "ViewController.h"

#define SCREEN_WIDTH [[UIScreen mainScreen] bounds].size.width
#define SCREEN_HEIGHT [[UIScreen mainScreen] bounds].size.height

@interface ViewController () <UITableViewDataSource, UITableViewDelegate>
{
  
  UITableView* mainTableView;
  NSMutableArray* cbArray;
}
@end

@implementation ViewController

- (void)configureTableView
{
  cbArray = [NSMutableArray array];
  
  mainTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 20, SCREEN_WIDTH, SCREEN_HEIGHT-20) style:UITableViewStylePlain];
  mainTableView.delegate = self;
  mainTableView.dataSource = self;
  mainTableView.backgroundColor = [UIColor whiteColor];
  mainTableView.backgroundView = nil;
  mainTableView.allowsMultipleSelectionDuringEditing = NO;
  mainTableView.separatorStyle = UITableViewCellSeparatorStyleSingleLineEtched;
  mainTableView.autoresizingMask = UIViewAutoresizingNone;
  [self.view addSubview:mainTableView];
}

- (void)viewDidLoad {
  [super viewDidLoad];
  // Do any additional setup after loading the view, typically from a nib.
  [self configureTableView];
  
  self.centralManager = [[CBCentralManager alloc] initWithDelegate:self queue:nil];
  
}

- (void)centralManagerDidUpdateState:(CBCentralManager *)central
{
  switch (central.state) {
    case CBManagerStatePoweredOff:
      NSLog(@"CoreBluetooth BLE hardware is powered off");
      break;
    case CBManagerStatePoweredOn:
      NSLog(@"CoreBluetooth BLE hardware is powered on and ready");
      [self.centralManager scanForPeripheralsWithServices:nil options:nil];
      break;
    case CBManagerStateResetting:
      NSLog(@"CoreBluetooth BLE hardware is resetting");
      break;
    case CBManagerStateUnauthorized:
      NSLog(@"CoreBluetooth BLE state is unauthorized");
      break;
    case CBManagerStateUnknown:
      NSLog(@"CoreBluetooth BLE state is unknown");
      break;
    case CBManagerStateUnsupported:
      NSLog(@"CoreBluetooth BLE hardware is unsupported on this platform");
      break;
    default:
      break;
  }
}

- (void)centralManager:(CBCentralManager *)central didDiscoverPeripheral:(CBPeripheral *)peripheral advertisementData:(NSDictionary *)advertisementData RSSI:(NSNumber *)RSSI
{
  CBPeripheral* currentPer = peripheral;
  
  if(![cbArray containsObject:currentPer])
  {
    [cbArray addObject:currentPer];
  }
  
  [mainTableView reloadData];
}

- (void)didReceiveMemoryWarning {
  [super didReceiveMemoryWarning];
  // Dispose of any resources that can be recreated.
}

#pragma mark UITableView Delegate

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
  static NSString *cellIdentifier = @"Cell";
  UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
  if (cell == nil) {
    cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellIdentifier];
  }
  
  cell.backgroundColor = [UIColor clearColor];
  cell.selectionStyle = UITableViewCellSelectionStyleDefault;
  
  CBPeripheral* currentPer = [cbArray objectAtIndex:indexPath.row];
  cell.textLabel.text = (currentPer.name ? currentPer.name : @"Not available");
  
  return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
  [tableView deselectRowAtIndexPath:indexPath animated:YES];
  
  CBPeripheral* currentPer = [cbArray objectAtIndex:indexPath.row];
  [self.centralManager connectPeripheral:currentPer options:nil];

}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
  return [NSString stringWithFormat:@"Total count %lu",(unsigned long)cbArray.count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
  return 40;
}

#pragma mark UITableView Datasource

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
  return 50;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)sectionIndex
{
  return cbArray.count;
}

//
- (void)centralManager:(CBCentralManager *)central didConnectPeripheral:(CBPeripheral *)peripheral {
  
  NSLog(@"Connection successfull to peripheral: %@",peripheral);
  
  //Do somenthing after successfull connection.
}

- (void)centralManager:(CBCentralManager *)central didFailToConnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error
{
  NSLog(@"Connection failed to peripheral: %@",peripheral);
  
  //Do something when a connection to a peripheral failes.
}


@end
