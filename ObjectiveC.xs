#include "EXTERN.h"
#include "perl.h"
#include "XSUB.h"

#include "ppport.h"

#include <dlfcn.h>

#include <objc/runtime.h>

typedef id ObjectiveC__id;

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
