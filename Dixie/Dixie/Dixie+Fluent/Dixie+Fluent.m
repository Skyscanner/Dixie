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

#import "Dixie+Fluent.h"

@implementation Dixie (Fluent)

-(Dixie*(^)(id<DixiePuppetMaking>)) PuppetMaker
{
    return ^Dixie*(id<DixiePuppetMaking> puppetMaker)
    {
        return [self puppetMaker:puppetMaker];
    };
}

-(Dixie*(^)(DixieProfileEntry*)) Profile
{
    return ^Dixie*(DixieProfileEntry* profile)
    {
        return [self profile:profile];
    };
}

-(Dixie*(^)(NSArray*)) Profiles
{
    return ^Dixie*(NSArray* arrayOfEntries)
    {
        return [self profiles:arrayOfEntries];
    };
}

-(void(^)()) Apply
{
    return ^void(){
        
        [self apply];
        
    };
}

-(void(^)(NSInteger)) ApplyWith
{
    return ^void(NSInteger seed){
        
        [self apply:seed];
        
    };
}

-(void(^)()) Revert
{
    return ^void(){
        
        [self revert];
        
    };
}

-(void(^)(DixieProfileEntry* entry)) RevertIt
{
    return ^void(DixieProfileEntry* entry){
        
        [self revert:entry];
        
    };
}

@end
