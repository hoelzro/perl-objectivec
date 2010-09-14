#include "EXTERN.h"
#include "perl.h"
#include "XSUB.h"

#include "ppport.h"

#include <dlfcn.h>

#include <objc/runtime.h>
#include <objc/message.h>

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

ObjectiveC::id send_to_object(self, target, method_name, ...)
        const char *self
        ObjectiveC::id target
        const char *method_name
    INIT:
        SEL method_sel;
        int nargs;
        id retVal;
        Method method = NULL;
        const char *returnType = NULL;
    CODE:
        nargs = items - 3;
        if(nargs != 0) {
            croak("Calling with more than one argument is not yet implemented\n");
        }
        method_sel = sel_getUid(method_name);
        method = class_getInstanceMethod(object_getClass(target), method_sel);
        returnType = method_copyReturnType(method);
        if(strncmp("@", returnType, 1)) {
            SV *errsv = get_sv("@", GV_ADD);
            sv_setpvf(errsv, "Non-id return types are not yet implemented (return type is '%s')", returnType);
            free(returnType);
            croak(NULL);
        }
        free(returnType);
        retVal = objc_msgSend(target, method_sel);
        RETVAL = retVal;
    OUTPUT:
        RETVAL

MODULE = ObjectiveC		PACKAGE = ObjectiveC::id

void DESTROY(self)
        SV *self
    CODE:
        /* no-op (until we release the object) */
        /* what about class objects? */
