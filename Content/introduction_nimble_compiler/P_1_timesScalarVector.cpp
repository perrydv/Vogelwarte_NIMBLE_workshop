#ifndef __P_1_TIMESSCALARVECTOR_CPP
#define __P_1_TIMESSCALARVECTOR_CPP
#ifndef R_NO_REMAP
#define R_NO_REMAP
#endif
#include <nimble/EigenTypedefs.h>
#include <Rmath.h>
#include <math.h>
#include <nimble/Utils.h>
#include <nimble/accessorClasses.h>
#include <iostream>
#include <nimble/RcppUtils.h>
#include "P_1_timesScalarVector.h"

NimArr<1, double>  timesScalarVector ( double ARG1_a_, NimArr<1, double> & ARG2_x_ )  {
NimArr<1, double> ans;
Map<MatrixXd> Eig_ans(0,0,0);
EigenMapStrd Eig_ARG2_x_Interm_1(0,0,0, EigStrDyn(0, 0));
ans.setSize(ARG2_x_.dim()[0], 0, 0);
new (&Eig_ans) Map< MatrixXd >(ans.getPtr(),ARG2_x_.dim()[0],1);
new (&Eig_ARG2_x_Interm_1) EigenMapStrd(ARG2_x_.getPtr() + static_cast<int>(ARG2_x_.getOffset() + static_cast<int>(0)),ARG2_x_.dim()[0],1,EigStrDyn(0, ARG2_x_.strides()[0]));
Eig_ans = ARG1_a_ * Eig_ARG2_x_Interm_1;
return(ans);
}

SEXP  CALL_timesScalarVector ( SEXP S_ARG1_a_, SEXP S_ARG2_x_ )  {
double ARG1_a_;
NimArr<1, double> ARG2_x_;
SEXP S_returnValue_1234;
NimArr<1, double> LHSvar_1234;
SEXP S_returnValue_LIST_1234;
ARG1_a_ = SEXP_2_double(S_ARG1_a_);
SEXP_2_NimArr<1>(S_ARG2_x_, ARG2_x_);
GetRNGstate();
LHSvar_1234 = timesScalarVector(ARG1_a_, ARG2_x_);
PutRNGstate();
PROTECT(S_returnValue_LIST_1234 = Rf_allocVector(VECSXP, 3));
PROTECT(S_returnValue_1234 = NimArr_2_SEXP<1>(LHSvar_1234));
PROTECT(S_ARG1_a_ = double_2_SEXP(ARG1_a_));
PROTECT(S_ARG2_x_ = NimArr_2_SEXP<1>(ARG2_x_));
SET_VECTOR_ELT(S_returnValue_LIST_1234, 0, S_ARG1_a_);
SET_VECTOR_ELT(S_returnValue_LIST_1234, 1, S_ARG2_x_);
SET_VECTOR_ELT(S_returnValue_LIST_1234, 2, S_returnValue_1234);
UNPROTECT(4);
return(S_returnValue_LIST_1234);
}
#endif
