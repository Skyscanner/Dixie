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

#import "NSObject+DixieRunTimeHelper.h"
#import <objc/runtime.h>
#import "DixieRunTimeHelper.h"

static char encodingKey;
static char originalValueKey;

@interface NSObject ()

@property (nonatomic, strong) NSValue* wrapper;

@end

@implementation NSObject (encoding)

#pragma mark - Encoding
-(void) setEncoding:(NSString*)encoding
{
	objc_setAssociatedObject(self, &encodingKey, encoding, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

-(NSString*) encoding
{
	return objc_getAssociatedObject(self, &encodingKey);
}

#pragma mark - Original value
-(void) setOriginalValue:(void *)originalValue
{
	NSValue* value = [NSValue valueWithPointer:originalValue];
	objc_setAssociatedObject(self, &originalValueKey, value, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

-(void*) originalValue
{
	NSValue* value = objc_getAssociatedObject(self, &originalValueKey);
	return [value pointerValue];
}

#pragma mark - Dealloc
//Do not forget to dealloc the original value
+ (void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        Class class = [self class];
        
        SEL originalSelector = NSSelectorFromString(@"dealloc");
        SEL swizzledSelector = NSSelectorFromString([DixieMethodPrefix stringByAppendingString:@"dealloc"]);
        
        Method originalMethod = class_getInstanceMethod(class, originalSelector);
        Method swizzledMethod = class_getInstanceMethod(class, swizzledSelector);
        
        BOOL didAddMethod =
        class_addMethod(class,
                        originalSelector,
                        method_getImplementation(swizzledMethod),
                        method_getTypeEncoding(swizzledMethod));
        
        if (didAddMethod) {
            class_replaceMethod(class,
                                swizzledSelector,
                                method_getImplementation(originalMethod),
                                method_getTypeEncoding(originalMethod));
        } else {
            method_exchangeImplementations(originalMethod, swizzledMethod);
        }
    });
}

- (void)dixie_dealloc{
    [self dixie_dealloc];
    
    void* original = self.originalValue;
    
    if (original)
    {
        free(original);
    }
}

@end
