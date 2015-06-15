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

#import "DixieBaseChaosProvider.h"

/**
 *  Block type, that can describe a method implementation
 *
 *  @param chaosProvider The DixieBaseChaosProvider, who is calling this block (to avoid retain cycles)
 *  @param victim        The class or instance of the class, that's method chould be changed
 *  @param environment   A DixieCallEnvironment, that describes the arguments and return value
 */
typedef void(^DixieCustomChaosBlock)(DixieBaseChaosProvider* chaosProvider,id victim, DixieCallEnvironment* environment);

/**
 *  Provides a behaviour, where the original method's implementation can be replaced by a custom block
 */
@interface DixieBlockChaosProvider : DixieBaseChaosProvider

/**
 *  Creates an instance of DixieBlockChaosProvider
 *
 *  @param block The block, that should be called as the method's implementation
 *
 *  @return a new instance of DixieBlockChaosProvider
 */
+(instancetype) block:(DixieCustomChaosBlock)block;

@end
