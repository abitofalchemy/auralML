/*
 * Copyright (c) 2017  STMicroelectronics – All rights reserved
 * The STMicroelectronics corporate logo is a trademark of STMicroelectronics
 *
 * Redistribution and use in source and binary forms, with or without modification,
 * are permitted provided that the following conditions are met:
 *
 * - Redistributions of source code must retain the above copyright notice, this list of conditions
 *   and the following disclaimer.
 *
 * - Redistributions in binary form must reproduce the above copyright notice, this list of
 *   conditions and the following disclaimer in the documentation and/or other materials provided
 *   with the distribution.
 *
 * - Neither the name nor trademarks of STMicroelectronics International N.V. nor any other
 *   STMicroelectronics company nor the names of its contributors may be used to endorse or
 *   promote products derived from this software without specific prior written permission.
 *
 * - All of the icons, pictures, logos and other images that are provided with the source code
 *   in a directory whose title begins with st_images may only be used for internal purposes and
 *   shall not be redistributed to any third party or modified in any way.
 *
 * - Any redistributions in binary form shall not include the capability to display any of the
 *   icons, pictures, logos and other images that are provided with the source code in a directory
 *   whose title begins with st_images.
 *
 * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR
 * IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY
 * AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER
 * OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
 * CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
 * SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY
 * THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR
 * OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY
 * OF SUCH DAMAGE.
 */

#import <UIKit/UIKit.h>

#import "BlueSTSDK/BlueSTSDKNode.h"
#import "BlueSTSDKViewControllerMenuDelegate.h"

/**
 *  Funcitons for personalise the node list view.
 */
@protocol BlueSTSDKNodeListViewControllerDelegate <NSObject>

/**
 *  Filter to use for decide if we have to display the node.
 *
 *  @param node node to filter.
 *
 *  @return true for display the node, false otherwise.
 */
-(bool) displayNode:(BlueSTSDKNode*)node;

/**
 *  Get the view controller to display when the node is selected.
 *
 *  @param node node seleceted by the user.
 *
 *  @return view controller to display after the seleciton.
 */
-(UIViewController*) demoViewControllerWithNode:(BlueSTSDKNode*)node
                                    menuManager:(id<BlueSTSDKViewControllerMenuDelegate>)menuManager;

@end

/**
 *  View controller that will contains all the list of device discovered.
 *  If the class is used inside an emulator it add a virtual node for simultate
 *  the Bluetooth
 */
@interface BlueSTSDKNodeListViewController : UITableViewController

/**
 *  delegate used for filter the nodes and decide what display when the node is selected
 */
@property id<BlueSTSDKNodeListViewControllerDelegate> delegate;

@end
