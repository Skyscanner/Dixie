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

#import "DixieRunTimeHelper.h"
#import "NSObject+DixieRunTimeHelper.h"

@interface NSInvocation (PrivateHack)
- (void)invokeUsingIMP: (IMP)imp;
@end

struct BlockDescriptor {
    unsigned long reserved;
    unsigned long size;
    void *rest[1];
};

struct Block {
    void *isa;
    int flags;
    int reserved;
    void *invoke;
    struct BlockDescriptor *descriptor;
};

@implementation DixieRunTimeHelper

#pragma mark - IMPLEMENTATION HELPERS
+(IMP) implementationWithChaosContext:(DixieChaosContext*)chaosContext environment:(DixieImplementationBlock)block;
{
    struct Block *blockWrapper = (__bridge void*)[self blockForSignature:chaosContext.methodInfo.signature block:block];
    
    struct BlockDescriptor *descriptor = blockWrapper->descriptor;
    
    int copyDisposeFlag = 1 << 25;
    int signatureFlag = 1 << 30;
    
    assert(blockWrapper->flags & signatureFlag);
    
    int index = 0;
    if(blockWrapper->flags & copyDisposeFlag)
        index += 2;
    
    //Make the block fit for any need
    descriptor->rest[index] = (void*)chaosContext.methodInfo.methodTypeEncoding;
    
    return imp_implementationWithBlock((__bridge id)(blockWrapper));
}

/**
 *  Returns a block implementation for a given signature
 *
 *  @param signature The method signature
 *  @param block     The body of the block implementation
 *
 *  @return A block, that matches the signature and calls the block
 */
+(id) blockForSignature:(NSMethodSignature*)signature block:(DixieImplementationBlock)block
{
#define BLOCK_ID                                                                                        \
    ^id(id victim, ...){                                                                                \
        va_list args;                                                                                   \
        va_start(args, victim);                                                                         \
                                                                                                        \
        NSArray* arguments = [self argumentsFor:signature originalArguments:args];                      \
        DixieCallEnvironment* environment = [[DixieCallEnvironment alloc] initWithArguments:arguments]; \
        block(victim, environment);                                                                     \
        return environment.returnValue;                                                                 \
    }
    
#define BLOCK(TYPE)                                                                                     \
    ^TYPE(id victim, ...){                                                                              \
        va_list args;                                                                                   \
        va_start(args, victim);                                                                         \
                                                                                                        \
        NSArray* arguments = [self argumentsFor:signature originalArguments:args];                      \
        DixieCallEnvironment* environment = [[DixieCallEnvironment alloc] initWithArguments:arguments]; \
        block(victim, environment);                                                                     \
        return *(TYPE *)environment.returnValue;                                                        \
    }
    
    const char* rType = signature.methodReturnType;
    
    if (isType(rType, void)) return BLOCK(void);
    if (isType(rType, BOOL)) return BLOCK(BOOL);
    if (isType(rType, int)) return BLOCK(int);
    if (isType(rType, char)) return BLOCK(char);
    if (isType(rType, double)) return BLOCK(double);
    if (isType(rType, float)) return BLOCK(float);
    if (isType(rType, long)) return BLOCK(long);
    
    return BLOCK_ID;
}

/**
 *  Parses a variadic list into array of objects
 @note The current solution handles only object,selector,BOOL and char types.
 *
 *  @param signature The signature to determine the type of parameters in the variadic list
 *  @param arguments The variadic list
 *
 *  @return Array of parsed objects
 */
+(NSArray*) argumentsFor:(NSMethodSignature*)signature originalArguments:(va_list)arguments
{
    //Ignore self and _cmd
    NSInteger numberOfParameters = signature.numberOfArguments-2;
    NSMutableArray* parameters = [NSMutableArray arrayWithCapacity:numberOfParameters];
    va_list iteratorList;
    __va_copy(iteratorList, arguments);
    
    for (NSInteger index = 0; index < numberOfParameters; index++) {
        
        //Only read argument after self and _cmd
        const char* argTyp = [signature getArgumentTypeAtIndex:index + 2];
        
        //Convert to object
        id parameter = [self objectFromNext:iteratorList type:argTyp outputArgumentList:&iteratorList];
        
        //Fill the unparsed value with NSNull
        parameter = parameter ? :[NSNull null];
        
        [parameters addObject:parameter];
    }
    
    return parameters;
}

+(void) callImplementation:(IMP)implementation on:(id)puppet chaosContext:(DixieChaosContext*)chaosContext environment:(DixieCallEnvironment*)environment
{
    NSMethodSignature* signature = chaosContext.methodInfo.signature;
    NSInvocation* invocation = [NSInvocation invocationWithMethodSignature:signature];
    
    [invocation setTarget:puppet];
    [invocation setSelector:chaosContext.methodInfo.selector];
    
    //We are ignoring the index of self and _cmd
    for (NSInteger i = 2; i < signature.numberOfArguments; i++) {
        
        const char* encoding = [signature getArgumentTypeAtIndex:i];
        
        if (isType(encoding, NSObject*) ||
            isType(encoding, void*) ||
            strcmp(encoding, "@?") == 0 )
        {
            id value = environment.arguments[i-2];
            if (value == [NSNull null]) {
                value = nil;
            }
            [invocation setArgument:&value atIndex:i];
        }
        else
        {
            void* value = [environment.arguments[i-2] originalValue];
            [invocation setArgument:value atIndex:i];
        }
    }
    
    [invocation invokeUsingIMP:implementation];
    
    if (!isType(chaosContext.methodInfo.signature.methodReturnType, void))
    {
        if(isType(chaosContext.methodInfo.signature.methodReturnType, id))
        {
            id returnValue;
            [invocation getReturnValue:&returnValue];
            environment.returnValue = (void*)CFBridgingRetain(returnValue);
        }
        else
        {
            void *returnValue = malloc(chaosContext.methodInfo.signature.methodReturnLength);
            environment.returnValue = returnValue;
        }
    }
}

#pragma mark - CONVERT OBJECT
/**
 *  Converts the next item in the variadic arguments list into subclass of NSObjects
 *  @note We are using core foundation factories here, NSNumber, NSString might be swizzled
 *
 *  @param arguments The variadic list
 *  @param argType   The expected type of the next item
 *  @param ova_List  The current state of the variadic list after the current value is read from it
 *
 *  @return An NSObject subclass that represents the argument
 */
+(NSObject *) objectFromNext:(va_list)arguments type:(const char*)argType outputArgumentList:(out void *)ova_List
{
    NSObject* object;
    
    //char
    //int
    //short
    //unsgined char
    //unsgined short
    //BOOL
    if (isType(argType, char) ||
        isType(argType, int) ||
        isType(argType, short) ||
        isType(argType, unsigned char) ||
        isType(argType, unsigned short) ||
        isType(argType, BOOL))
    {
        int i = va_arg(arguments, int);
        
        object = CFBridgingRelease(CFNumberCreate(kCFAllocatorDefault, kCFNumberIntType, &i));
        
        storeOriginal(object, int, i);
    }
    //long
    else if (isType(argType, long))
    {
        long l = va_arg(arguments, long);
        
        object = CFBridgingRelease(CFNumberCreate(kCFAllocatorDefault, kCFNumberLongType, &l));
        object.originalValue = &l;
    }
    //long long
    else if (isType(argType, long long))
    {
        long long ll = va_arg(arguments, long long);
        
        object = CFBridgingRelease(CFNumberCreate(kCFAllocatorDefault, kCFNumberLongLongType, &ll));
        object.originalValue = &ll;
    }
    //unsgined int
    else if (isType(argType, unsigned int))
    {
        unsigned int ui = va_arg(arguments, unsigned int);
        
        object = CFBridgingRelease(CFNumberCreate(kCFAllocatorDefault, kCFNumberIntType, &ui));
        
        storeOriginal(object, unsigned int, ui);
    }
    //unsgined long
    else if (isType(argType, unsigned long))
    {
        unsigned long ul = va_arg(arguments, unsigned long);
        
        object = CFBridgingRelease(CFNumberCreate(kCFAllocatorDefault, kCFNumberLongType, &ul));
        
        storeOriginal(object, unsigned long, ul);
    }
    //unsgined long long
    else if (isType(argType, unsigned long long))
    {
        unsigned long long ull = va_arg(arguments, unsigned long long);
        
        object = CFBridgingRelease(CFNumberCreate(kCFAllocatorDefault, kCFNumberLongLongType, &ull));
        
        storeOriginal(object, unsigned long long, ull);
    }
    //float
    //double
    else if (isType(argType, float) || isType(argType, double) )
    {
        double real = va_arg(arguments, double);
        
        object = CFBridgingRelease(CFNumberCreate(kCFAllocatorDefault, kCFNumberDoubleType, &real));
        
        storeOriginal(object, double, real);
    }
    //char string
    else if (isType(argType, char*))
    {
        char* string = va_arg(arguments, char*);
        
        object = CFBridgingRelease(CFStringCreateWithCString(NULL, string, kCFStringEncodingUTF8));
        object.originalValue = string;
    }
    //Object
    else if (strcmp(argType, "@") == 0   ||//NSObject
             strcmp(argType, "no@") == 0 || //NSObject?
             strcmp(argType, "@?") == 0  //Block
             )
    {
        id data = va_arg(arguments, id);
        
        object = strcmp(argType, "@?") == 0 ? [data copy] : data;
    }
    //class
    else if (isType(argType, Class))
    {
        Class klass = va_arg(arguments, Class);
        
        object = NSStringFromClass(klass);
        
        storeOriginal(object, Class, klass);
    }
    //SEL
    else if (isType(argType, SEL))
    {
        SEL selector = va_arg(arguments, SEL);
        
        object = NSStringFromSelector(selector);
        
        storeOriginal(object, SEL, selector);
    }
    //Output pointer
    else if (argType[0] == '^')
    {
        void* outputParam = va_arg(arguments, void*);
        
        object = [NSValue valueWithPointer:outputParam];
    }
    
    //Set the original encoding on the object
    [object setEncoding:[NSString stringWithUTF8String:argType]];
    
    ova_List = &arguments;
    
    return object;
}

#pragma mark - INFO HELPER
+(NSArray*) selectorsForClass:(Class)targetClass
{
    unsigned int count;
    Method* methods = class_copyMethodList(targetClass, &count);
    
    NSMutableArray* selectorNames = [@[] mutableCopy];
    
    for (NSInteger i = 0; i < count; i++) {
        
        Method method = methods[i];
        SEL selector = method_getName(method);
        NSString* selectorName = NSStringFromSelector(selector);
        
        if (selectorName)
        {
            [selectorNames addObject:selectorName];
        }
    }
    
    free(methods);
    
    return selectorNames;
}

+(Method) methodForMethodInfo:(DixieMethodInfo*)methodInfo
{
    if (methodInfo.isClassMethod)
    {
        return class_getClassMethod(methodInfo.targetClass, methodInfo.selector);
    }
    else
    {
        return class_getInstanceMethod(methodInfo.targetClass, methodInfo.selector);
    }
}

+(const char*) methodTypeEncodingForMethodInfo:(DixieMethodInfo*)methodInfo
{
    Method method = [self methodForMethodInfo:methodInfo];
    return method_getTypeEncoding(method);
}

+(Class) classForMethodInfo:(DixieMethodInfo*)methodInfo
{
    if (methodInfo.isClassMethod)
    {
        return object_getClass((id)methodInfo.targetClass);
    }
    else
    {
        return methodInfo.targetClass;
    }
}

@end
