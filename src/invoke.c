// vim:ft=objc

#include "EXTERN.h"
#include "perl.h"

#import <Foundation/NSInvocation.h>
#import <Foundation/NSMethodSignature.h>
#import <Foundation/NSString.h>
#import <objc/runtime.h>

void marshal_perl_value(AV *arguments, NSInvocation *invocation, unsigned int index)
{
    croak("Invalid # of arguments");
    //[invocation setArgument: buffer atIndex: index + 2];
}

SV *demarshal_return_value(NSInvocation *invocation)
{
    const char *return_type = NULL;
    HV *stash = NULL;
    SV *result = NULL;
    id object = nil;
    const char *string = NULL;

    return_type = [[invocation methodSignature] methodReturnType];
    if(return_type[0] == _C_CONST) {
        return_type++;
    }
    switch(return_type[0]) {
        case _C_ID:
            [invocation getReturnValue: &object];
            result = newRV_inc(newSViv(object));
            stash = gv_stashpv("ObjectiveC::id", 0);
            sv_bless(result, stash);
            break;
        case _C_CHARPTR:
            [invocation getReturnValue: &string];
            result = newSVpv(string, 0);
            break;
        default:
            croak("Bad return type: %c", return_type[0]);
    }
    return result;
}

SV *invoke_with_perl_args(id target, SV *selector_name, AV *arguments)
{
    Class class = Nil;
    SEL selector = nil;
    Method method = NULL;
    NSInvocation *invocation = nil;
    SV *result = &PL_sv_undef;
    unsigned int nargs = 0;
    unsigned int i = 0;
    void *return_buffer = NULL;

    //# error handling
    class = object_getClass(target);
    selector = sel_registerName(SvPVX(selector_name));
    method = class_getInstanceMethod(class, selector);
    // +2 for self and _cmd
    if(av_len(arguments) + 1 != method_getNumberOfArguments(method) - 2) {
        NSString *description = [target description];
        croak("Bad number of arguments provided when calling '%s' on '%s' (expected: %d actual: %d)", sel_getName(selector), [description UTF8String], method_getNumberOfArguments(method) - 2, av_len(arguments) + 1);
    }
    invocation = [NSInvocation invocationWithMethodSignature: [target methodSignatureForSelector: selector]];

    [invocation setSelector: selector];
    [invocation setTarget: target];

    for(i = 0; i < nargs; i++) {
        marshal_perl_value(arguments, invocation, i);
    }

    [invocation invoke];

    result = demarshal_return_value(invocation);

    return result;
}
