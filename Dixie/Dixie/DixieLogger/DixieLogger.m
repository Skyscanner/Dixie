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

#include "DixieLogger.h"
#include "DixieSimpleLogger.h"

@implementation DixieLogger

static DixieLogger* _logger;

+ (instancetype)defaultLogger
{
    return _logger;
}

+ (void) setDefaultLogger:(DixieLogger*)logger
{
    if (logger == nil)
        @throw [NSException exceptionWithName:@"ArgumentNil" reason:@"logger is nil" userInfo: nil];
    
    _logger = logger;
}

+(void) load
{
    [super load];
    
    _logger = [DixieSimpleLogger new];
}

- (void)log:(NSString*)format,...
{
    @throw [NSException exceptionWithName:@"Method not overriden" reason:@"DixLogger subclasses should override [DixLogger log:]" userInfo: nil];
}

@end
