// @(#)root/pyroot:$Id$
// Author: Wim Lavrijsen, Aug 2004

// Bindings
#include "PyROOT.h"
#include "TClassMethodHolder.h"
#include "Adapters.h"


//- constructors/destructor -----------------------------------------------------
PyROOT::TClassMethodHolder::TClassMethodHolder( const TScopeAdapter& klass, const TMemberAdapter& method ) :
      TMethodHolder( klass, method )
{
}


//- public members --------------------------------------------------------------
PyObject* PyROOT::TClassMethodHolder::operator()(
      ObjectProxy*, PyObject* args, PyObject* kwds, Long_t user, Bool_t release_gil )
{
// preliminary check in case keywords are accidently used (they are ignored otherwise)
   if ( kwds != 0 && PyDict_Size( kwds ) ) {
      PyErr_SetString( PyExc_TypeError, "keyword arguments are not yet supported" );
      return 0;
   }

// setup as necessary
   if ( ! this->Initialize() )
      return 0;                              // important: 0, not Py_None

// translate the arguments
   if ( ! this->SetMethodArgs( args, user ) )
      return 0;                              // important: 0, not Py_None

// execute function
   return this->Execute( 0, release_gil );
}
