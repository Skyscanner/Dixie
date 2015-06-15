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
#import "DixieMethodInfo.h"

/**
 *  Defining the context for the DixieChaosProviders
 */
@interface DixieChaosContext : NSObject

/**
 *  A seed for deterministic behaviour.
 */
@property (readonly) NSInteger seed;

/**
 *  A DixieMethodInfo, that describes the class and one of its method
 */
@property (readonly) DixieMethodInfo* methodInfo;

/**
 *  The original implementation of the class method, described in the methodInfo property.
 */
@property IMP originalIMP;

/**
 *  Creates a DixieChaosContext with a given seed and methodInfo
 *
 *  @param seed       A seed for deterministic behaviour.
 *  @param methodInfo A DixieMethodInfo, that describes the class and one of its method
 *
 *  @return A DixieChaosContext
 */
-(instancetype) init:(NSInteger)seed methodInfo:(DixieMethodInfo*)methodInfo;

@end
