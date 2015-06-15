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

#import "DixiePuppetMaking.h"
#import "DixieProfileEntry.h"

/**
 *  Represents a Dixie configuration.
 */
@interface Dixie : NSObject

/**
 *  Sets the default puppetmaker
 *
 *  @param puppetMaker An object that conforms to the PuppetMaking protocol.
 *
 *  @return The active Dixie object
 */
-(instancetype) puppetMaker:(id<DixiePuppetMaking>)puppetMaker;

/**
 *  Registers a single profiles.
 *
 *  @param profile A DixieProfileEntry objects.
 *
 *  @return Same Dixie object.
 */
-(instancetype) profile:(DixieProfileEntry*)profile;

/**
 *  Registers profiles.
 *
 *  @param arrayOfEntries Collection of DixieProfileEntry objects.
 *
 *  @return Same Dixie object.
 */
-(instancetype) profiles:(NSArray*)arrayOfEntries;

/**
 *  Applies the Dixie configuration.
 */
-(void) apply;

/**
 *  Applies the Dixie configuration with the specified seed (used for random generation).
 *
 *  @param seed The seed for random generation
 */
-(void) apply:(NSInteger)seed;

/**
 *  Reverts the Dixie configuration.
 */
-(void) revert;

/**
 *  Reverts one DixieProfileEntry from the Dixie configuration.
 *
 *  @param entry The profile to revert
 */
-(void) revert:(DixieProfileEntry*)entry;

@end
