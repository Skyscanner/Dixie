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

#import "TestClass.h"

@implementation TestClass

+ (void)classDoNothing
{
    
}

- (id)returnValue
{
    return @2;
}

- (void)throwException
{
    @throw [NSException exceptionWithName:@"Test" reason:@"Arbitrary reason" userInfo:nil];
}

- (void)doNothing
{
    
}

-(void) setChar:(char)aChar frame:(CGRect)frame
{
    
}

@end
