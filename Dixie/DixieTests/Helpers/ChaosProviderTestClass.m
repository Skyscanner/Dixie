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

@end
