#include "EXTERN.h"
#include "perl.h"
#include "XSUB.h"

#include "ppport.h"

#include <dlfcn.h>

#include <objc/runtime.h>
#include <objc/message.h>

typedef id ObjectiveC__id;

extern SV *invoke_with_perl_args(id, SV *, AV *);

AV *get_selector_and_args(pTHX_ SV *selector_name)
{
    dSP;
    dMARK;
    dITEMS;
    dAX;

    AV *arguments = NULL;
    int nargs = items - 3;
    int i;

    arguments = newAV();

    if(nargs > 0) {
        if(nargs % 2 == 0) {
            croak("Even number of arguments passed to send_to_object");
        }

        sv_catpv(selector_name, ":");
        av_push(arguments, ST(3));

        for(i = 1; i < nargs; i += 2) {
            sv_catsv(selector_name, ST(i + 3));
            sv_catpv(selector_name, ":");
            av_push(arguments, ST(i + 3 + 1));
        }
    }

    return arguments;
}

MODULE = ObjectiveC		PACKAGE = ObjectiveC

void load_framework(self, name)
        const char *self
        const char *name
    CODE:
        char *fullname = NULL;
        size_t fullname_len = 0;
        void *handle;

        fullname_len = strlen(name);
        fullname_len *= 2;
        fullname_len += sizeof(".framework/");

        fullname = malloc(fullname_len);

        snprintf(fullname, fullname_len, "%s.framework/%s", name, name);
        handle = dlopen(fullname, RTLD_LAZY);
        free(fullname);
        if(! handle) {
            croak("Unable to load framework '%s': %s", name, dlerror());
        }
        dlclose(handle);

ObjectiveC::id get_class(self, name)
        const char *self
        const char *name
    CODE:
        ObjectiveC__id class = objc_getClass(name);
        if(! class) {
            croak("No such class '%s'", name);
        }
        RETVAL = class;
    OUTPUT:
        RETVAL

void get_class_list(self)
        const char *self
    PREINIT:
        Class *classes = NULL;
        int numClasses = 0;
        int i;
    PPCODE:
        numClasses = objc_getClassList(NULL, 0);
        classes = malloc(sizeof(Class) * numClasses);
        if(! classes) {
            croak("Failed to allocate memory for class list");
        }
        objc_getClassList(classes, numClasses);
        EXTEND(SP, numClasses);
        for(i = 0; i < numClasses; i++) {
            const char *name = class_getName(classes[i]);
            PUSHs(sv_2mortal(newSVpv(name, 0)));
        }
        free(classes);

SV *send_to_object(self, target, method_name, ...)
        const char *self
        ObjectiveC::id target
        const char *method_name
    INIT:
        SV *selector_name = NULL;
        AV *arguments = NULL;
        SV *return_value = NULL;
    CODE:
        selector_name = newSVpv(method_name, 0);
        arguments = get_selector_and_args(aTHX_ selector_name);
        return_value = invoke_with_perl_args(target, selector_name, arguments);
        RETVAL = return_value;
    OUTPUT:
        RETVAL

MODULE = ObjectiveC		PACKAGE = ObjectiveC::id

void DESTROY(self)
        SV *self
    CODE:
        /* no-op (until we release the object) */
        /* what about class objects? */
