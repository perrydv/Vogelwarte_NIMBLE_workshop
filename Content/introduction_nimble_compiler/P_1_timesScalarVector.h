#ifndef __P_1_TIMESSCALARVECTOR
#define __P_1_TIMESSCALARVECTOR
#ifndef R_NO_REMAP
#define R_NO_REMAP
#endif
#include <nimble/NimArr.h>
#include <Rinternals.h>
#include <nimble/accessorClasses.h>
#include <nimble/nimDists.h>
#include <nimble/nimOptim.h>

NimArr<1, double>  timesScalarVector ( double ARG1_a_, NimArr<1, double> & ARG2_x_ );

extern "C" SEXP  CALL_timesScalarVector ( SEXP S_ARG1_a_, SEXP S_ARG2_x_ );
#endif
