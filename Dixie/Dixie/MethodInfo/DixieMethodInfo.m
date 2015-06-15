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

#import "DixieMethodInfo.h"
#import "DixieRunTimeHelper.h"

@interface DixieMethodInfo()

@property Class targetClass;
@property SEL selector;
@property BOOL isClassMethod;
@property (nonatomic, strong) NSMethodSignature* signature;
@property const char* methodTypeEncoding;

@end

@implementation DixieMethodInfo

+(instancetype) infoWithClass:(Class)targetClass selector:(SEL)selector;
{
    DixieMethodInfo* method = [DixieMethodInfo new];
    
    method.targetClass = targetClass;
    method.selector = selector;
    method.isClassMethod = [targetClass respondsToSelector:selector];
    
    if (method.isClassMethod)
    {
        method.signature = [targetClass methodSignatureForSelector:selector];
    }
    else
    {
        method.signature = [targetClass instanceMethodSignatureForSelector:selector];
    }
    
    method.methodTypeEncoding = [DixieRunTimeHelper methodTypeEncodingForMethodInfo:method];
    
    return method;
}

@end


