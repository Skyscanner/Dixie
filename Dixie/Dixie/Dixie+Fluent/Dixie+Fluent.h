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

#import "Dixie.h"

/**
 *  Fluent API of Dixie for easier configuration
 *  @code [Dixie new].Profile(aProfile).Apply();
 */
@interface Dixie (Fluent)

@property (nonatomic, readonly) Dixie*(^PuppetMaker)(id<DixiePuppetMaking> puppetMaker);
@property (nonatomic, readonly) Dixie*(^Profile)(DixieProfileEntry* profile);
@property (nonatomic, readonly) Dixie*(^Profiles)(NSArray* arrayOfEntries);
@property (nonatomic, readonly) void(^Apply)();
@property (nonatomic, readonly) void(^ApplyWith)(NSInteger seed);
@property (nonatomic, readonly) void(^Revert)();
@property (nonatomic, readonly) void(^RevertIt)(DixieProfileEntry* entry);

@end
