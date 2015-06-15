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

#import "DixieBaseParamProvider.h"

/**
 *  Provides a random number object
 */
@interface DixieRandomParamProvider : DixieBaseParamProvider

/**
 *  Creates a DixieRandomParamProvider with a given uppper bound
 *
 *  @param upperBound The upper limit to the random numbers, the numbers can be only lower than this
 *
 *  @return a DixieRandomParamProvider
 */
+(instancetype) providerWithUpperBound:(unsigned int)upperBound;

/**
 *  Set the seed for the random generator
 *
 *  @param seed A seed for deterministic behaviour
 */
-(void) setSeed:(unsigned long long)seed;

@end
