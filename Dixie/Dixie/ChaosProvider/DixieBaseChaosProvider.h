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

#import "DixieChaosContext.h"
#import "DixieRunTimeHelper.h"

@interface DixieBaseChaosProvider : NSObject

@property (nonatomic, strong) DixieChaosContext* context;

/**
 *  Returns a new behaviour implementation
 *
 *  @return An implementation pointer
 */
-(IMP) chaos;

/**
 *  Will forward the result of one DixieChaosProvider to the next.
 *
 *  @param victim        The class or instance of the class, that's method should be changed
 *  @param environment   A DixieCallEnvironment, that describes the arguments and return value
 *  @param chaosProvider The target DixieBaseChaosProvider, who should provider the behaviour
 */
-(void) forwardChaosOf:(id)victim environment:(DixieCallEnvironment*)environment to:(DixieBaseChaosProvider*)chaosProvider;

/**
 *  The behaviour implementation
 *
 *  @param victim      The class or instance of the class, that's method should be changed
 *  @param environment A DixieCallEnvironment, that describes the arguments and return value
 */
-(void) chaosImplementationFor:(id) victim environment:(DixieCallEnvironment*)environment;

@end
