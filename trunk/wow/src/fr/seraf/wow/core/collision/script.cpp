/*
		script.cpp

    Main Xtra source code. Most of it comes from Macromedia's Scripting Xtra Skeleton2
     
    -------------------------------------------------------------------------
    
    Macromedia Director Xtra to check if the given point is inside the given polygon
    
    Some more documentation can be found at http://pro.wanadoo.fr/freextras/
    
    Copyright (C) 2006 Laurent Cozic
    Contact: laurent1979@laposte.net

    This program is free software; you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation; either version 2 of the License, or
    (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with this program; if not, write to the Free Software
    Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
    
    -------------------------------------------------------------------------
*/

#define INITGUID 1

#include "script.h"

#include <string.h>
#include <stdlib.h>
#include "xclassver.h"
#include "moatry.h"

#include "driservc.h"
#include "drivalue.h"

#include "mmivalue.h"
#include "mmillist.h"
#include "mmiplist.h"
#include "mmidate.h"
#include "mmiclr.h"


/*******************************************************************************
 * SCRIPTING XTRA MESSAGE TABLE DESCRIPTION.
 *
 * The general format is:
 * xtra <nameOfXtra>
 * new object me [ args ... ]
 * <otherHandlerDefintions>
 * --
 * The first line must give the name of the Scripting xtra.
 * The remaining lines give the names of the handlers that this xtra implements
 * along with the required types of the arguments for each handler.
 * 
 * -- Pre-defined handler new 
 * The new handler will be called when a child object is created, 
 * the first argument is always the child object and you defined any remaining arguments.
 * The new handler is the place to initialize any memory required by the child object.
 * 
 * -- Simple Handler Definitions
 * Each handler definition line is format like this:
 * <handlerName> <argType1> <argName1>, <argType2> <argName2> ...
 * The first word is the handler name. Following this are types description for
 * the argument to the handler, each separated by a comma.
 * The argument name <argName>, may be omited.
 * Permited argument types are: 
 * 	integer 
 * 	float
 * 	string
 * 	symbol
 * 	object
 * 	any
 * 	*
 * For integer, float, string, symbol, and object, the type of the argument must 
 * match. The type any means allow any type. The asterisk (*) means any number and 
 * any type of arguments.
 * 
 * The first argument is the child object and is always declared to be of type object.
 * 
 * -- Global Handlers
 * An asterisk (*) preceeding the handler name signifies a global handler.
 * This handler is at the global scope level and can be called from any
 * movie.
 * 
 * -- Xtra level handlers
 * A plus (+) preceeding the handler name signifies an Xtra level handler. 
 * This kind of handler can be called directly from the Xtra reference,
 * without creating a child object.
 * 
 * The enumerated list that follows must correspond directly with the msgTable 
 * (i.e. they must be in the same order).
 * 
 *******************************************************************************/ 
 
 /* This is the list of handlers for the xtra. The versionInfo string is combined
 /*	with the msgTable string in the register method to create a single string that
 /* used when registering the xtra as a scripting xtra. */

static char versionInfo[] = "xtra PointInsidePolygon -- version %s.%s.%s\n";
static char msgTable[] = { 
	"new object me\n"  /* standard first handler entry in all message tables */
 	"-- Template handlers --\n" 
	"* PointInsidePolygon * XCoordinate, * YCoordinate, List PolygonPointList -- boolean\n"
	"* PointInsidePolygonEC * XCoordinate, * YCoordinate, List PolygonPointList -- boolean\n"
		/*
		 * ---> insert additional handler(s) MUST MATCH WITH ENUMS BELOW -->
		 */ 
	};


/* 	This is the enumerated scripting method list. This list should
 *	directly correspond to the msgTable defined above. It is used
 *	to dispatch method calls via the methodSelector. The 'm_XXXX' method must
 *	be last.
 */

enum 
{
	m_new = 0, /* standard first entry */
	m_PointInsidePolygon,
	m_PointInsidePolygonEC,
		/*
		 * ---> insert additional names(s) MUST MATCH MESSAGE TABLE ABOVE -->
		 */ 
	m_XXXX
};


/* ============================================================================= */
/* Xtra Glue Stuff */
/* ============================================================================= */

#define XTRA_VERSION_NUMBER XTRA_CLASS_VERSION

BEGIN_XTRA
	BEGIN_XTRA_DEFINES_CLASS(TStdXtra, XTRA_CLASS_VERSION)
		CLASS_DEFINES_INTERFACE(TStdXtra, IMoaRegister, XTRA_VERSION_NUMBER)
		CLASS_DEFINES_INTERFACE(TStdXtra, IMoaMmXScript, XTRA_VERSION_NUMBER)
		/*
		 * ---> insert additional interface(s) -->
		 */ 
	END_XTRA_DEFINES_CLASS
END_XTRA


/* ============================================================================= */
/* Create/Destroy for class TStdXtra */
/* ============================================================================= */


STDMETHODIMP_(MoaError) MoaCreate_TStdXtra (TStdXtra FAR * This)
{
moa_try
		
	ThrowErr (This->pCallback->QueryInterface(&IID_IMoaMmValue, (PPMoaVoid) &This->pValueInterface));
	ThrowErr (This->pCallback->QueryInterface(&IID_IMoaMmUtils2, (PPMoaVoid) &This->pMoaUtils));
	ThrowErr (This->pCallback->QueryInterface(&IID_IMoaMmList, (PPMoaVoid) &This->pListInterface));
	ThrowErr (This->pCallback->QueryInterface(&IID_IMoaDrPlayer, (PPMoaVoid) &This->pPlayerInterface));
	
moa_catch
moa_catch_end
moa_try_end
}

STDMETHODIMP_(void) MoaDestroy_TStdXtra(TStdXtra FAR * This)
{
moa_try

	if (This->pValueInterface != NULL) 
		ThrowErr (This->pValueInterface->Release());
		
	if (This->pMoaUtils != NULL) 
		ThrowErr (This->pMoaUtils->Release());

	if (This->pListInterface != NULL) 
		ThrowErr (This->pListInterface->Release());

	if (This->pPlayerInterface != NULL) 
		ThrowErr (This->pPlayerInterface->Release());

moa_catch
moa_catch_end
moa_try_end_void
}


/* ============================================================================= */
/* Methods in TStdXtra_IMoaRegister */
/* ============================================================================= */

/*****************************************************************************
 *  Data needed for Registering
 *	---------------------------
 *	Specific code needed to register different types of Xtras.  The skeleton
 *	source files include minimal implementations appropriate for each Xtra
 *	type.  Current necessary actions:
 *
 *	Scripting Xtra:				Add the Scripting Xtra Message Table
 *	Sprite Asset Xtra:			Nothing
 *	Tool Xtra:					Nothing
 *	Transition Asset Xtra		Nothing
 *
 *  ****optional: Register as Safe for Shockwave!
 *****************************************************************************/ 

STD_INTERFACE_CREATE_DESTROY(TStdXtra, IMoaRegister)

BEGIN_DEFINE_CLASS_INTERFACE(TStdXtra, IMoaRegister)
END_DEFINE_CLASS_INTERFACE

/* ----------------------------------------------------------------------------- */
STDMETHODIMP TStdXtra_IMoaRegister::Register(
	PIMoaCache pCache, 
	PIMoaXtraEntryDict pXtraDict
)
{	
moa_try
	PIMoaRegistryEntryDict		pReg;
	MoaBool						bItsSafe = TRUE;
	char versionStr[256];
	PMoaVoid pMemStr = NULL;

	/* Register the lingo xtra */
	ThrowErr(pCache->AddRegistryEntry(pXtraDict, &CLSID_TStdXtra, &IID_IMoaMmXScript, &pReg));

	/* Register the method table */
	sprintf(versionStr, versionInfo, VER_MAJORVERSION_STRING, VER_MINORVERSION_STRING, VER_BUGFIXVERSION_STRING);
	pMemStr = pObj->pCalloc->NRAlloc(sizeof(msgTable) + sizeof(versionStr));
	ThrowNull(pMemStr);

	strcpy((char *)pMemStr, versionStr);
	strcat((char *)pMemStr, msgTable);

	ThrowErr(pReg->Put(kMoaDrDictType_MessageTable, pMemStr, 0, kMoaDrDictKey_MessageTable));

	/* Mark xtra as safe for shockwave - but only if it IS safe ! */
	
	ThrowErr(pReg->Put(kMoaMmDictType_SafeForShockwave, &bItsSafe, sizeof(bItsSafe), kMoaMmDictKey_SafeForShockwave));
	

moa_catch
moa_catch_end
	if (pMemStr)
		pObj->pCalloc->NRFree(pMemStr);
moa_try_end
}



/* ============================================================================= */
/*  Methods in TStdXtra_IMoaMmXScript */
/* ============================================================================= */

BEGIN_DEFINE_CLASS_INTERFACE(TStdXtra, IMoaMmXScript)
END_DEFINE_CLASS_INTERFACE

//******************************************************************************
TStdXtra_IMoaMmXScript::TStdXtra_IMoaMmXScript(MoaError FAR * pError)
//------------------------------------------------------------------------------
{
	*pError = kMoaErr_NoErr;
}	

//******************************************************************************
TStdXtra_IMoaMmXScript::~TStdXtra_IMoaMmXScript()
//------------------------------------------------------------------------------
{
}


/* ----------------------------------------------------------------------------- */
STDMETHODIMP TStdXtra_IMoaMmXScript::Call (PMoaDrCallInfo callPtr)
{
moa_try
	switch	( callPtr->methodSelector ) 
	{
		case m_new:
			{
			/* Setup any instance vars for you Xtra here. new() is
			called via Lingo when creating a new instance. */
			/*
			 * --> insert additional code -->
		 	 */
			}
			break;
					
		/* Here is where new methods are added to the switch statement. Each
		   method should be defined in the msgTable defined in and have a 
		   constant defined in the associated enum. 
		*/  

		case m_PointInsidePolygon:
			ThrowErr(PointInsidePolygon(callPtr));
			break;

		case m_PointInsidePolygonEC:
			ThrowErr(PointInsidePolygonEC(callPtr));
			break;

		/*
		 * --> insert additional methodSelector cases -->
		 */

	}
moa_catch
moa_catch_end
moa_try_end
}



/*****************************************************************************
 *  Private Methods
 *  -------------------
 *  Implementation of Private Class Methods
 /*
 *  This is the actual code for the defined methods. They are defined as 
 *  functions, and called from the switch statement in Call().
 *
 ****************************************************************************/


// --- pnpoly ---
// Comes from Nick Fotis's computer graphics resources FAQ:
// http://www.faqs.org/faqs/graphics/algorithms-faq/
int pnpoly(int npol, float *xp, float *yp, float x, float y)
{
  int i, j, c = 0;
  for (i = 0, j = npol-1; i < npol; j = i++) {
    if ((((yp[i]<=y) && (y<yp[j])) ||
         ((yp[j]<=y) && (y<yp[i]))) &&
        (x < (xp[j] - xp[i]) * (y - yp[i]) / (yp[j] - yp[i]) + xp[i]))
      c = !c;
  }
  return c;
}


// --- PointInsidePolygon(
//				<float or integer> point X coordinate,
//				<float or integer> point Y coordinate,
//				<list> polygon)
MoaError TStdXtra_IMoaMmXScript::PointInsidePolygon(PMoaDrCallInfo pCall)
{
moa_try

#define PX thePoint[0]
#define PY thePoint[1]
	
	MoaMmValue	mmValue;
	MoaDouble* thePoint = new MoaDouble[2];
	// PARAMETER 1: Get the X coordinate of the point
	pciGetArgByIndex(pCall, 1, &mmValue);
    pObj->pValueInterface->ValueToFloat(&mmValue, &PX);
    pObj->pValueInterface->ValueRelease(&mmValue);

    // PARAMETER 2: Get the Y coordinate of the point
    pciGetArgByIndex(pCall, 2, &mmValue);
    pObj->pValueInterface->ValueToFloat(&mmValue, &PY);
    pObj->pValueInterface->ValueRelease(&mmValue);

    // PARAMETER 3: Get the polygon
    MoaLong     countPoints;
    MoaMmValue  polygon;
    pciGetArgByIndex(pCall, 3, &polygon);
    // Count the number of points
    countPoints = pObj->pListInterface->CountElements(&polygon);

	int i;
	MoaMmValue coordValue;
	float* xp = new float[countPoints];
	float* yp = new float[countPoints];
	MoaDouble pointX;
	MoaDouble pointY;

	for (i = 1; i <= countPoints; i++) {
        // Get the first point value from the list
        pObj->pListInterface->GetValueByIndex(&polygon, i, &mmValue);
        // Get the X coordinate
        pObj->pListInterface->GetValueByIndex(&mmValue, 1, &coordValue);
		pObj->pValueInterface->ValueToFloat(&coordValue, &pointX);
        pObj->pValueInterface->ValueRelease(&coordValue);
        // Get the Y coordinate
        pObj->pListInterface->GetValueByIndex(&mmValue, 2, &coordValue);
        pObj->pValueInterface->ValueToFloat(&coordValue, &pointY);
        pObj->pValueInterface->ValueRelease(&coordValue);
		pObj->pValueInterface->ValueRelease(&mmValue);
		
		xp[i-1] = float(pointX);
		yp[i-1] = float(pointY);
	}

	//Return the result
	int result = pnpoly(countPoints, xp, yp, float(PX), float(PY));
	delete(xp);
	delete(yp);
	ThrowErr(pObj->pValueInterface->IntegerToValue(result, &pCall->resultValue));

moa_catch
moa_catch_end	
moa_try_end	
}



// The same as above but with more error checking on the input parameters
// as giving wrong values can crash Director with a fatal error.
MoaError TStdXtra_IMoaMmXScript::PointInsidePolygonEC(PMoaDrCallInfo pCall)
{
moa_try

#define M_WRONG_TYPE_ERROR \
	MoaMmSymbol errorCode; \
	pObj->pValueInterface->StringToSymbol("wrongType", &errorCode); \
	ThrowErr(pObj->pValueInterface->SymbolToValue(errorCode, &pCall->resultValue));

#define M_WRONG_VALUE \
	((valueType != kMoaMmValueType_Integer) && (valueType != kMoaMmValueType_Float))
	

#define PX thePoint[0]
#define PY thePoint[1]
	
	MoaMmValue	mmValue;
	MoaDouble* thePoint = new MoaDouble[2];
	MoaMmValueType valueType;
	int typeError = 0;
	
	// PARAMETER 1: Get the X coordinate of the point
	pciGetArgByIndex(pCall, 1, &mmValue);
	// Check its value
	pObj->pValueInterface->ValueType(&mmValue, &valueType);
	pObj->pValueInterface->ValueRelease(&mmValue);
	if M_WRONG_VALUE {
		typeError = 1;
	} else {
		// PARAMETER 2: Get the Y coordinate of the point
		pciGetArgByIndex(pCall, 2, &mmValue);
		// Check its value
		pObj->pValueInterface->ValueType(&mmValue, &valueType);
		pObj->pValueInterface->ValueRelease(&mmValue);
		if M_WRONG_VALUE {
			typeError = 2;
		} else {
		    // PARAMETER 3: Get the polygon
			MoaLong     countPoints;
		    MoaMmValue  polygon;
			pciGetArgByIndex(pCall, 3, &polygon);
			// Count the number of points
			countPoints = pObj->pListInterface->CountElements(&polygon);
			int i;
			MoaMmValue coordValue;
			for (i = 1; i <= countPoints; i++) {
		        // Get the point value from the list
				pObj->pListInterface->GetValueByIndex(&polygon, i, &mmValue);
				// Get the X coordinate
				pObj->pListInterface->GetValueByIndex(&mmValue, 1, &coordValue);
				// Check its value
				pObj->pValueInterface->ValueType(&coordValue, &valueType);
				pObj->pValueInterface->ValueRelease(&coordValue);
				if M_WRONG_VALUE {
					typeError = 3;
					pObj->pValueInterface->ValueRelease(&polygon);
					break;
				}
				// Get the Y coordinate
				pObj->pListInterface->GetValueByIndex(&mmValue, 2, &coordValue);
				// Check its value
				pObj->pValueInterface->ValueType(&coordValue, &valueType);
				pObj->pValueInterface->ValueRelease(&coordValue);
				pObj->pValueInterface->ValueRelease(&mmValue);
				if M_WRONG_VALUE {
					typeError = 3;
					pObj->pValueInterface->ValueRelease(&polygon);
					break;
				}
			}
		}
	}
	
	if (typeError != 0) {
		MoaMmSymbol errorCode;
		pObj->pValueInterface->StringToSymbol("wrongType", &errorCode);
		ThrowErr(pObj->pValueInterface->SymbolToValue(errorCode, &pCall->resultValue));
	} else {
		this->PointInsidePolygon(pCall);
	}

moa_catch
moa_catch_end	
moa_try_end	
}
