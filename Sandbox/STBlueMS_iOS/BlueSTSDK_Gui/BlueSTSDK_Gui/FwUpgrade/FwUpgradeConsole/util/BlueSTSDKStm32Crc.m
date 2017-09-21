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

#import "BlueSTSDKStm32Crc.h"

static const uint32_t INITIAL_VALUE = 0xffffffff;
static const uint32_t CRC_TABLE[] = { // Nibble lookup table for 0x04C11DB7 polynomial
0x00000000, 0x04C11DB7, 0x09823B6E, 0x0D4326D9, 0x130476DC, 0x17C56B6B, 0x1A864DB2, 0x1E475005,
0x2608EDB8, 0x22C9F00F, 0x2F8AD6D6, 0x2B4BCB61, 0x350C9B64, 0x31CD86D3, 0x3C8EA00A, 0x384FBDBD};



static uint32_t Crc32Fast(uint32_t Crc, uint32_t Data) {
    Crc = Crc ^ Data; // Apply all 32-bits

    // Process 32-bits, 4 at a time, or 8 rounds

    Crc = (Crc << 4) ^ CRC_TABLE[Crc >> 28]; // Assumes 32-bit reg, masking index to 4-bits
    Crc = (Crc << 4) ^ CRC_TABLE[Crc >> 28]; //  0x04C11DB7 Polynomial used in STM32
    Crc = (Crc << 4) ^ CRC_TABLE[Crc >> 28];
    Crc = (Crc << 4) ^ CRC_TABLE[Crc >> 28];
    Crc = (Crc << 4) ^ CRC_TABLE[Crc >> 28];
    Crc = (Crc << 4) ^ CRC_TABLE[Crc >> 28];
    Crc = (Crc << 4) ^ CRC_TABLE[Crc >> 28];
    Crc = (Crc << 4) ^ CRC_TABLE[Crc >> 28];

    return (Crc);
}

@implementation BlueSTSDKStm32Crc {}

+ (instancetype)crcEngine {
    return [[BlueSTSDKStm32Crc alloc] init];
}

-(instancetype) init{
    self = [super init];
    _crcValue=INITIAL_VALUE;
    return self;
}

- (void)upgrade:(NSData *)data {

    if(data.length%4!=0)
        @throw [NSException exceptionWithName:@"Invalid data" reason:@"Length must be multiple of 4" userInfo:nil];

    uint32_t value;
    for(NSUInteger i =0 ;i < data.length ; i+=4){
        [data getBytes:&value range:NSMakeRange(i,4)];
        _crcValue=Crc32Fast(_crcValue,value);
    }
}


@end
