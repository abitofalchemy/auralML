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

#import "BlueSTSDKFwUpgradeConsoleNucleo.h"
#import "BlueSTSDKStm32Crc.h"

#define GET_VERSION_BOARD_FW @"versionFw\r\n"

#define MAX_MSG_SIZE ((NSUInteger)16)
#define N_BLOCK_PACKAGE 10
#define MSG_DELAY_NS (NSEC_PER_SEC/90)
#define LOST_MSG_TIMEOUT_S (1.5f)

#define ACK_MSG {0x01,'\0'}

static dispatch_queue_t sTimeOutQueue;

#define ADD_TIMEOUT(fun,time) \
    {\
        dispatch_sync(sTimeOutQueue, ^{ \
            [self performSelector:  @selector(fun) withObject:nil afterDelay:time];\
        });\
    }\

#define REMOVE_TIMEOUT(fun) \
    {\
        dispatch_sync(sTimeOutQueue, ^{ \
            [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(fun) object:nil];\
        });\
    }\

@interface ReadFwVersionDelegate : NSObject<BlueSTSDKDebugOutputDelegate>

+(instancetype)getReadFwVersionDelegate:(BlueSTSDKFwUpgradeConsole *)console;
-(instancetype)init:(BlueSTSDKFwUpgradeConsole*)console;

@end

@implementation ReadFwVersionDelegate{
    BlueSTSDKFwUpgradeConsole *mFwUpgradeConsole;
    NSMutableString *mBuffer;
}

+(instancetype)getReadFwVersionDelegate:(BlueSTSDKFwUpgradeConsole*)console{
    return [[ReadFwVersionDelegate alloc]init:console];
}

-(instancetype)init:(BlueSTSDKFwUpgradeConsole*)console{
    self = [super init];
    mFwUpgradeConsole=console;
    mBuffer = [NSMutableString string];
    return self;
}

-(void) onTimeoutIsFired{
    [mFwUpgradeConsole setConsoleDelegate:nil];
    if(mFwUpgradeConsole.delegateReadVersion!=nil){
        [mFwUpgradeConsole.delegateReadVersion fwUpgrade:mFwUpgradeConsole didVersionRead:nil];
    }
}

-(void) debug:(BlueSTSDKDebug*)debug didStdOutReceived:(NSString*) msg{
    REMOVE_TIMEOUT(onTimeoutIsFired)
    
    if([ msg hasSuffix:@"\r\n"]){
        [mBuffer appendString:[msg substringWithRange:NSMakeRange(0, [msg length]-2)]];
        [mFwUpgradeConsole setConsoleDelegate:nil];
        if(mFwUpgradeConsole.delegateReadVersion!=nil){
            @try {
                BlueSTSDKFwVersion *version = [BlueSTSDKFwVersion version:mBuffer];
                [mFwUpgradeConsole.delegateReadVersion fwUpgrade:mFwUpgradeConsole didVersionRead:version];
            }@catch (NSException *exception){
                [mFwUpgradeConsole.delegateReadVersion fwUpgrade:mFwUpgradeConsole didVersionRead:nil];
            }
        }
    }else{
        [mBuffer appendString:msg];
        ADD_TIMEOUT(onTimeoutIsFired, LOST_MSG_TIMEOUT_S)
        
    }

}

-(void) debug:(BlueSTSDKDebug*)debug didStdInSend:(NSString*) msg error:(NSError*)error{
    ADD_TIMEOUT(onTimeoutIsFired, LOST_MSG_TIMEOUT_S)
}

-(void) debug:(BlueSTSDKDebug*)debug didStdErrReceived:(NSString*) msg{}
@end

@interface LoadFwDelegate : NSObject<BlueSTSDKDebugOutputDelegate>

+(instancetype)getLoadFwDelegate:(BlueSTSDKFwUpgradeConsole *)console fwData:(NSData *)data fileUrl:(NSURL*)url;
-(void)startLoading;

@end

@implementation LoadFwDelegate{
    BlueSTSDKFwUpgradeConsole *mFwUpgradeConsole;
    BOOL mNodeReadyToReceiveFile;
    uint32_t mNPackageReceived;
    NSUInteger mByteSend;
    uint32_t mCrc;
    NSData *mFwData;
    NSURL *mFwUrl;
    NSString *mAckString;
}

+(instancetype)getLoadFwDelegate:(BlueSTSDKFwUpgradeConsole*)console fwData:(NSData *)data fileUrl:(NSURL*)url{
    return [[LoadFwDelegate alloc]init:console fwData:data fileUrl:url];
}


-(instancetype)init:(BlueSTSDKFwUpgradeConsole*)console fwData:(NSData *)data fileUrl:(NSURL*)url{
    self = [super init];
    mFwUpgradeConsole=console;
    mFwData=data;
    mFwUrl=url;
    mByteSend=0;
    mNodeReadyToReceiveFile=false;
    char ackMsg[] = ACK_MSG;
    mAckString = [NSString stringWithCString:ackMsg encoding:NSISOLatin1StringEncoding];
    return self;
}


- (void)startLoading {
    mCrc = [self computeCrc: mFwData];
    [mFwUpgradeConsole.console writeMessageData:
     [LoadFwDelegate prepareLoadCommand:(uint32_t)mFwData.length crc:mCrc]];
}

-(void)onLoadFailWithError:(BlueSTSDKFwUpgradeUploadFwError) error{
    if(mFwUpgradeConsole.delegateLoadFw!=nil)
        [mFwUpgradeConsole.delegateLoadFw fwUpgrade:mFwUpgradeConsole
                                        onLoadError:mFwUrl error:error];
    [mFwUpgradeConsole setConsoleDelegate:nil];
}

-(void)onLoadComplite{
    if(mFwUpgradeConsole.delegateLoadFw!=nil)
        [mFwUpgradeConsole.delegateLoadFw fwUpgrade:mFwUpgradeConsole onLoadComplite:mFwUrl];
    [mFwUpgradeConsole setConsoleDelegate:nil];
}

+ (NSData *)prepareLoadCommand:(uint32_t)length crc:(uint32_t)crc {
    char command[] = {'u','p','g','r','a','d','e','F','w'};
    NSMutableData  *cmd = [NSMutableData dataWithBytes:command length:sizeof(command)];

    [cmd appendBytes:&length length:4];
    [cmd appendBytes:&crc length:4];

    return cmd;
}

- (uint32_t)computeCrc:(NSData *)data {
    NSUInteger length = data.length-data.length%4;
    NSData *tempData = [NSData dataWithBytesNoCopy:(void *) data.bytes
                                            length:length
                                      freeWhenDone:NO];
    BlueSTSDKStm32Crc *crcEngine = [BlueSTSDKStm32Crc crcEngine];
    [crcEngine upgrade:tempData];
    return crcEngine.crcValue;
}

-(BOOL)checkCrc:(NSString *)str{
    NSData *data = [str dataUsingEncoding:NSISOLatin1StringEncoding];
    uint32_t ackCrc;
    [data getBytes:&ackCrc length:4];
    return ackCrc == mCrc;
}

-(void) debug:(BlueSTSDKDebug*)debug didStdOutReceived:(NSString*) msg {
    if (!mNodeReadyToReceiveFile) {
        if ([self checkCrc:msg]) {
            mNodeReadyToReceiveFile = true;
            mNPackageReceived = 0;
            [self sendPackageBlock];
        } else
            [self onLoadFailWithError:BLUESTSDK_FWUPGRADE_UPLOAD_ERROR_TRANSMISSION];
    } else { //transfer complete
        REMOVE_TIMEOUT(onTimeoutIsFired)
        if([msg compare:mAckString] == NSOrderedSame){
            [mFwUpgradeConsole.delegateLoadFw fwUpgrade:mFwUpgradeConsole
                                          onLoadProgres:mFwUrl
                                              loadBytes:0];
            [self onLoadComplite];
        }else{
            [self onLoadFailWithError:BLUESTSDK_FWUPGRADE_UPLOAD_CORRUPTED_FILE];
        }
    }//if
}


/**
* read the data from the file and send it to the node
* @return true if the package is correctly sent
*/
-(BOOL)sendFwPackage{
    NSUInteger lastPackageSize = MIN(mFwData.length - mByteSend, MAX_MSG_SIZE);

    if(lastPackageSize==0)
        return true;

    NSData  *dataPkg = [NSData dataWithBytesNoCopy:((uint8_t*)mFwData.bytes)+mByteSend
                                            length:lastPackageSize
                                      freeWhenDone:NO];

    if(dataPkg==nil || dataPkg.length!=lastPackageSize)
        return FALSE;

    mByteSend += lastPackageSize;
    [mFwUpgradeConsole.console writeMessageDataFast:dataPkg];
    return true;

}//sendFwPackage

/**
 * send a block of message, the function will stop at the first error
 */
-(void) sendPackageBlock{
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, MSG_DELAY_NS), dispatch_get_main_queue(), ^{
        if([self sendFwPackage]){
            [self sendPackageBlock];
        }
    });

}//sendPackageBlock

/**
 * notify to the user that a block of data is correctly send and send a new one
 */
-(void) notifyNodeReceivedFwMessage{
    mNPackageReceived++;
    if(mNPackageReceived % N_BLOCK_PACKAGE ==0){
        [mFwUpgradeConsole.delegateLoadFw fwUpgrade:mFwUpgradeConsole
                                      onLoadProgres:mFwUrl
                                          loadBytes:mFwData.length-mByteSend];
    }//if
}

-(void) debug:(BlueSTSDKDebug*)debug didStdInSend:(NSString*) msg error:(NSError*)error{

    if(error!=nil) {
        [self onLoadFailWithError:BLUESTSDK_FWUPGRADE_UPLOAD_ERROR_TRANSMISSION];
        return;
    }//else
    if(mNodeReadyToReceiveFile){
        //reset the timeout
        REMOVE_TIMEOUT(onTimeoutIsFired)
        [self notifyNodeReceivedFwMessage];
        ADD_TIMEOUT(onTimeoutIsFired, LOST_MSG_TIMEOUT_S)
    }
}

- (void)onTimeoutIsFired {
    [self onLoadFailWithError:BLUESTSDK_FWUPGRADE_UPLOAD_ERROR_TRANSMISSION];
}

-(void) debug:(BlueSTSDKDebug*)debug didStdErrReceived:(NSString*) msg{}
@end


@implementation BlueSTSDKFwUpgradeConsoleNucleo {

}
+ (BlueSTSDKFwUpgradeConsole *)instance:(BlueSTSDKDebug *)debug {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sTimeOutQueue = dispatch_queue_create("FW_TIMEOUT", DISPATCH_QUEUE_SERIAL);
    });

    BlueSTSDKFwUpgradeConsole *console = [[BlueSTSDKFwUpgradeConsoleNucleo alloc] init];
    console.console=debug;
    return console;
}

-(BOOL)readFwVersion:(id <BlueSTSDKFwUpgradeReadVersionDelegate>)delegate{
    if ([self isWaitingAnswer])
        return false;

    self.delegateReadVersion =delegate;

    [self setConsoleDelegate:
     [ReadFwVersionDelegate getReadFwVersionDelegate:self]];

    [self.console writeMessage:GET_VERSION_BOARD_FW];

    return true;
}



- (BOOL)loadFwFile:(NSURL *)file delegate:(id <BlueSTSDKFwUpgradeUploadFwDelegate>)delegate {
    if ([self isWaitingAnswer])
        return false;

    self.delegateLoadFw =delegate;

    NSError *error=nil;

    NSFileHandle *fwFile = [NSFileHandle fileHandleForReadingFromURL:file error:&error];

    if(error!=nil){
        [self.delegateLoadFw fwUpgrade:self onLoadError:file error:BLUESTSDK_FWUPGRADE_UPLOAD_ERROR_INVALID_FW_FILE];
        return true;
    }

    NSData *data = [fwFile readDataToEndOfFile];

    LoadFwDelegate *consoleDelegate = [LoadFwDelegate getLoadFwDelegate:self fwData:data fileUrl:file];
    [self setConsoleDelegate:consoleDelegate];

    [consoleDelegate startLoading];

    return true;
}




@end
