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

@import Foundation;

#import "DixieBaseChaosProvider.h"

/**
 *  Describes which chaosProvider should define the method's behaviour if the argument at index, matches the given value. DixieCompositeChaosProvider uses this object to delegate the implementation to different providers.
 */
@interface DixieCompositeCondition : NSObject

/**
 *  The index of the argument to check
 */
@property (readonly) NSInteger index;

/**
 *  The value of the argument we wish to compare
 */
@property (readonly) id value;

/**
 *  The ChaosProvider to apply
 */
@property (readonly) DixieBaseChaosProvider* chaosProvider;

/**
 *  Creates a DixieCompositeCondition
 *
 *  @param index         The index of the argument to check
 *  @param value         The value to compare the argument against
 *  @param chaosProvider The DixieChaosProvider to apply, if the argument matches the value
 *
 *  @return a DixieCompositeCondition
 */
+(instancetype) condition:(NSInteger)index value:(id)value chaosProvider:(DixieBaseChaosProvider*)chaosProvider;

@end