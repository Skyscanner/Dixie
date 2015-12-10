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

#import "ChaosProviderTestClass.h"

@implementation ChaosProviderTestClass

- (instancetype)init
{
    self = [super init];
    if (self) {
        
    }
    return self;
}

+ (void)classDoNothing
{
    
}

-(id)returnValue
{
    return @2;
}

-(NSNumber*) numberFromInteger:(int)integer
{
    return @(integer);
}

-(NSString*) variadicMethod:(id)key,... NS_REQUIRES_NIL_TERMINATION
{
    return @"";
}

-(int)returnIntValue
{
    return 42;
}

- (void)throwException
{
    @throw [NSException exceptionWithName:@"Test" reason:@"Arbitrary reason" userInfo:nil];
}

- (void)doNothing
{
    
}

-(void) setNumber:(int)number object:(NSNumber *)numberObj block:(dispatch_block_t)block;
{
    
}

-(void) setChar:(char)aChar frame:(CGRect)frame
{
    
}

-(short) _veryPrivateMethod
{
    return 0;
}

-(id) arg1:(NSNumber *)arg1 arg2:(NSInteger)arg2 arg3:(double)arg3 arg4:(float)arg4 arg5:(int)arg5 arg6:(int*)arg6 arg7:(BOOL)arg7 arg8:(char)arg8 arg9:(short)arg9 arg10:(long)arg10
{
    return [@(arg1.integerValue + arg2 + arg3 + arg4 + arg5 + *arg6 + arg7 +arg8 + arg9 + arg10) stringValue];
}

-(float) valueFrom:(double)doubleValue
{
    return [@(doubleValue) floatValue];
}

-(TestBlockType) block
{
    return ^int(double d, BOOL b){ return b ? d : 42;};
}

@end

@implementation ChaosProviderTestClass (aCategory)

-(unsigned int) randomIntFrom:(int)k
{
    return arc4random_uniform(k);
}

@end

