/*****************************************************************************
 * Project: RooFit                                                           *
 * Package: RooFitModels                                                     *
 *    File: $Id: RooNonCPEigenDecay.rdl,v 1.8 2004/04/05 22:38:35 wverkerke Exp $
 * Authors:                                                                  *
 *   AH, Andreas Hoecker,  Orsay,            hoecker@slac.stanford.edu       *
 *   SL, Sandrine Laplace, Orsay,            laplace@slac.stanford.edu       *
 *   JS, Jan Stark,        Paris,            stark@slac.stanford.edu         *
 *   WV, Wouter Verkerke,  UC Santa Barbara, verkerke@slac.stanford.edu      *
 *                                                                           *                  
 * Copyright (c) 2000-2004, Regents of the University of California,         *
 *                          IN2P3. All rights reserved.                      *
 *                                                                           *
 * History                                                                   *
 *   Nov-2001   WV Created initial version                                   *
 *   Dec-2001   SL mischarge correction, direct CPV                          *
 *   Jan-2002   AH built dedicated generator + code cleaning                 *
 *   Mar-2002   JS committed debugged version to CVS                         *
 *   Apr-2002   AH allow prompt (ie, non-Pdf) mischarge treatment            *
 *   May-2002   JS Changed the set of CP parameters (mathematically equiv.)  *
 *                                                                           *
 * Redistribution and use in source and binary forms,                        *
 * with or without modification, are permitted according to the terms        *
 * listed in LICENSE (http://roofit.sourceforge.net/license.txt)             *
 *****************************************************************************/
#ifndef ROO_NONCPEIGEN_DECAY
#define ROO_NONCPEIGEN_DECAY

#include "RooFitCore/RooAbsAnaConvPdf.hh"
#include "RooFitCore/RooRealProxy.hh"
#include "RooFitCore/RooCategoryProxy.hh"

class RooNonCPEigenDecay : public RooAbsAnaConvPdf {

public:

  enum DecayType { SingleSided, DoubleSided, Flipped };

  // Constructors, assignment etc
  inline RooNonCPEigenDecay( void ) { }

  // with explicit mischarge
  RooNonCPEigenDecay( const char *name, const char *title, 
		      RooRealVar&     t, 
	              RooAbsCategory& tag,
		      RooAbsReal&     tau, 
		      RooAbsReal&     dm,
		      RooAbsReal&     avgW, 
		      RooAbsReal&     delW, 
		      RooAbsCategory& rhoQ, 
		      RooAbsReal&     correctQ, 
		      RooAbsReal&     wQ,
		      RooAbsReal&     a,
		      RooAbsReal&     C,
		      RooAbsReal&     delC,
		      RooAbsReal&     S,
		      RooAbsReal&     delS,
		      const RooResolutionModel& model, 
		      DecayType       type = DoubleSided );

  // no explicit mischarge (=> set to zero)
  RooNonCPEigenDecay( const char *name, const char *title, 
		      RooRealVar&     t, 
	              RooAbsCategory& tag,
		      RooAbsReal&     tau, 
		      RooAbsReal&     dm,
		      RooAbsReal&     avgW, 
		      RooAbsReal&     delW, 
		      RooAbsCategory& rhoQ, 
		      RooAbsReal&     correctQ, 
		      RooAbsReal&     a,
		      RooAbsReal&     C,
		      RooAbsReal&     delC,
		      RooAbsReal&     S,
		      RooAbsReal&     delS,
		      const RooResolutionModel& model, 
		      DecayType       type = DoubleSided );

  RooNonCPEigenDecay(const RooNonCPEigenDecay& other, const char* name=0);
  virtual TObject* clone(const char* newname) const { 
    return new RooNonCPEigenDecay(*this,newname); 
  }
  virtual ~RooNonCPEigenDecay( void );

  virtual Double_t coefficient( Int_t basisIndex ) const;

  virtual Int_t getCoefAnalyticalIntegral( RooArgSet& allVars, 
  					   RooArgSet& analVars ) const;
  virtual Double_t coefAnalyticalIntegral( Int_t coef, Int_t code ) const;

  Int_t getGenerator( const RooArgSet& directVars, 
		      RooArgSet&       generateVars, Bool_t staticInitOK=kTRUE ) const;
  void initGenerator( Int_t code );
  void generateEvent( Int_t code );

protected:

  RooRealProxy     _acp ;
  RooRealProxy     _avgC ;
  RooRealProxy     _delC ;
  RooRealProxy     _avgS ;
  RooRealProxy     _delS ;
  RooRealProxy     _avgW ;
  RooRealProxy     _delW ;
  RooRealProxy     _t ;
  RooRealProxy     _tau;
  RooRealProxy     _dm;
  RooCategoryProxy _tag;
  RooCategoryProxy _rhoQ;
  RooRealProxy     _correctQ;
  RooRealProxy     _wQ;
  Double_t         _genB0Frac;
  Double_t         _genRhoPlusFrac;
  
  DecayType        _type;
  Int_t            _basisExp;
  Int_t            _basisSin;
  Int_t            _basisCos;

  ClassDef(RooNonCPEigenDecay,1) // PDF to model CP-violating decays to final states 
                                 // which are not CP eigenstates
};

#endif
