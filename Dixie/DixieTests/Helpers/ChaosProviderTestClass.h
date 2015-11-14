//
// Dixie
// Copyright 2015 Skyscanner Limited
//
// Licensed under the Apache License, Version 2.0 (the "License"); you may not use this file except in compliance with the License.
// You may obtain a copy of the License at:
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and limitations under the License.

#import <Foundation/Foundation.h>
#import <CoreGraphics/CGGeometry.h>

typedef int(^TestBlockType)(double, BOOL);

@protocol ChaosProviderTestClassDelegate <NSObject>

-(BOOL) isItTrue;

@end

/*!
 A class to test various method types
 */
@interface ChaosProviderTestClass : NSObject

@property (nonatomic, weak) id<ChaosProviderTestClassDelegate> testDelegate;

-(id) returnValue;
-(NSNumber*) numberFromInteger:(int)integer;
-(NSString*) variadicMethod:(id)key,... NS_REQUIRES_NIL_TERMINATION;
-(int) returnIntValue;

+(void) classDoNothing;
-(void) throwException;
-(void) doNothing;

-(void) setNumber:(int)number object:(NSNumber *)numberObj block:(dispatch_block_t)block;
-(void) setChar:(char)aChar frame:(CGRect)frame;

-(id) arg1:(NSNumber *)arg1 arg2:(NSInteger)arg2 arg3:(double)arg3 arg4:(float)arg4 arg5:(int)arg5 arg6:(int*)arg6 arg7:(BOOL)arg7 arg8:(char)arg8 arg9:(short)arg9 arg10:(long)arg10;
-(float) valueFrom:(double)doubleValue;
-(TestBlockType) block;

@end

@interface ChaosProviderTestClass(aCategory)

-(unsigned int) randomIntFrom:(int)k;

@end

