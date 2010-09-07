#include "EXTERN.h"
#include "perl.h"
#include "XSUB.h"

#include "ppport.h"

#include <dlfcn.h>

#ifdef __APPLE_CC__
# include <objc/runtime.h>
#else
# include <objc/objc-api.h>
#endif

typedef Class ObjectiveC__Class;

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

ObjectiveC::Class get_class(self, name)
        const char *self
        const char *name
    CODE:
#ifdef __APPLE_CC__
        ObjectiveC__Class class = objc_getClass(name);
#else
        ObjectiveC__Class class = objc_get_class(name);
#endif
        if(! class) {
            croak("No such class '%s'", name);
        }
        RETVAL = class;
    OUTPUT:
        RETVAL

void get_class_list(self)
        const char *self
    PREINIT:
#ifdef __APPLE_CC__
        Class *classes = NULL;
        int numClasses = 0;
        int i;
#else
        int numClasses = 0;
        void *enum_state = NULL;
        Class class;
#endif
    PPCODE:
#ifdef __APPLE_CC__
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
#else
        while(objc_next_class(&enum_state)) {
            numClasses++;
        }
        EXTEND(SP, numClasses);
        enum_state = NULL;
        while(class = objc_next_class(&enum_state)) {
            const char *name = class_get_class_name(class);
            PUSHs(sv_2mortal(newSVpv(name, 0)));
        }
#endif
