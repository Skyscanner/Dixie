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
#import "DixieMethodInfo.h"

/**
 *  Describe the target class, selector and the desired behaviour
 */
@interface DixieProfileEntry : NSObject

/**
 *  Uniquely identifies the entry
 */
@property (readonly) NSString* entryID;

/**
 *  The DixieMethodInfo object, that describes the class and its method
 */
@property (nonatomic, readonly) DixieMethodInfo* methodInfo;

/**
 *  The ChaosProvider which will provide the new implementation
 */
@property (nonatomic, strong) DixieBaseChaosProvider* chaosProvider;


/**
 *  Creates a DixieProfileEntry with the main properties set
 *
 *  @param victim        The victim whose method we wish to override
 *  @param selector      The selector for the method we wish to override
 *  @param chaosProvider The ChaosProvider which will provide the new implementation
 *
 *  @return a new DixieProfileEntry with the properties set
 */
+(instancetype) entry:(Class)victim selector:(SEL)selector chaosProvider:(DixieBaseChaosProvider*)chaosProvider;

/**
 *  Creates an array of DixieProfileEntry.
 *  The DixieProfileEntry array consists of all selectors on the victim EXCEPT those defined in the klass
 *
 *  @param victim        The victim whose method we wish to override
 *  @param klass         Tha class, whose selectors should not be added to the list of entries
 *  @param chaosProvider The ChaosProvider which will provide the new implementation
 *
 *  @return an array of DixieProfileEntries representing all available selectors on the victim EXCEPT those defined in the excludeClass
 */
+(NSArray*) entries:(Class)victim excludeSelectorsOfClass:(Class)excludeClass chaosProvider:(DixieBaseChaosProvider *)chaosProvider;

/**
 *  Creates an array of DixieProfileEntries
 *  The DixieProfileEntries array consists of all selectors on the victim EXCEPT those specified in excludedSelectorNames
 *
 *  @param victim                The victim whose method we wish to override
 *  @param excludedSelectorNames The selectors we do NOT wish to include in the return calue
 *  @param chaosProvider         The ChaosProvider which will provide the new implementation
 *
 *  @return an array of DixieProfileEntries representing all available selectors on the victim EXCEPT those specified
 */
+(NSArray*) entries:(Class)victim excludes:(NSArray*)excludedSelectorNames chaosProvider:(DixieBaseChaosProvider*)chaosProvider;

@end
