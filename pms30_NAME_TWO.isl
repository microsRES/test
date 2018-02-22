//
// This SIM script invokes events that are used by client to update the Order
// Confirmation Boards (OCB).
//
// _NOTE_
//privet
//  The DLL calls made by the SIM script are (as of 09-Apr-2007) part of a
//  public interface implemented by 3rd-party vendors. OCB client implement
//  the functions defined and expect the SIM script to invoke the functions as
//  documented. 
//
//  Please refer to documentation in the OCBClient project for additional
//  details about the interface. 
//

//
//
// SIM OPTIONS 
//
RetainGlobalVar
SetSignOnLeft

//
//
// Globals
//
var gv_dllHandle     : N12
var gv_dllFileName   : A256  // used to store filename of DLL currently loaded
var gv_bDisplayVoids : N1
var gv_bSendFlag     : N1
var gv_IVersion      : N12   // Interface version of loaded DLL 

var LOG_FILE_ENABLED                       : N1     //0 - no log, 1 - lcreate logs 

//
// flag use to short-circuit execution of EvalCapabilities()
//
var _CAPABILITIES_KNOWN: N1  

// Set true if Conversation Ordering Mode is supported
var SUPPORTS_COM: N1  
var SUPPORTS_OM: N1  
var SUPPORTS_DTL_IS_AUTO_DISCOUNT: N1  
var SUPPORTS_DTL_IS_COUPON: N1  

//
//
// Constant Defines
//
var INQ_OCB_START       : N5 = 1
var INQ_OCB_STOP        : N5 = 2
var INQ_CLAIM_1         : N5 = 3
var INQ_CLAIM_2         : N5 = 4
var INQ_TEMP_CLAIM_1    : N5 = 5
var INQ_TEMP_CLAIM_2    : N5 = 6
var INQ_RELEASE_CURRENT : N5 = 10
var INQ_FORCE_RELEASE_1 : N5 = 7
var INQ_FORCE_RELEASE_2 : N5 = 8
var INQ_SET_SEND_FLAG   : N5 = 9
var INQ_OCB_INFO        : N5 = 99

var TRUE                : N1 = 1
var FALSE               : N1 = 0

var PLEASE_WAIT_PROMPT  : A33 = "Communicating with OCB..."

var MAX_MSG_LEN         : N10 = 78

//
//
// Pre-public version of the interface (maintains compatibility with private
// MICROS release of the DLL)
//
var I_VERSION_0       : N12 = 0  
//
// Initial public version of the interface
//
var I_VERSION_1       : N12 = 1
//
// Modified the OCB_TransferDtlItem() function 
// Changed path used to load the DLL 
//
var I_VERSION_2       : N12 = 2
//
// Changed the signature of the OCB_TransferDtlItem() function so that much more
// information could be passed.
//
var I_VERSION_3       : N12 = 3
//
// Changed the signature of the OCB_EndOrder() function to include reason for 
// the event.
//
var I_VERSION_4       : N12 = 4

var MIN_I_VERSION     : N12 = I_VERSION_0
var MAX_I_VERSION     : N12 = I_VERSION_4

//
//
//  Inquiry Events
//

//
// Displays status information about the interface
//
//  This event allows the user to view information from the OCB client and is
//  intended as a support/installation troubleshooting tool.
//
event inq : INQ_OCB_INFO
   call LogMessage("Start Event INQ_OCB_INFO")

   if (gv_dllHandle <> 0)

      var prefixText: A32 = "Disabled"
      var voidText: A32 = "Disabled"
      var vendorMsg: A(MAX_MSG_LEN)
      var statusMsg: A(MAX_MSG_LEN)

      if (gv_IVersion > I_VERSION_0)

        prompt PLEASE_WAIT_PROMPT      

        dllcall_cdecl gv_dllHandle, OCB_Status(ref vendorMsg, ref statusMsg, MAX_MSG_LEN)

      endif

      if (@PREFIX_DTL_NAME)
        prefixText = "Enabled"
      endif

      if (gv_bDisplayVoids)
        voidText = "Enabled"
      endif

     window 8, MAX_MSG_LEN, "OCB Status"
     display 1, 1, "DLL File        : ", gv_dllFileName   
     display 2, 1, "Menu Item Prefix: ", prefixText
     display 3, 1, "Display Voids   : ", voidText
     display 4, 1, ""
     display 5, 1, vendorMsg
     display 6, 1, statusMsg
     display 7, 1, ""

     waitForClear

   else

     infoMessage "OCB interface is not currently loaded"

   endif
  
   call LogMessage("End Event INQ_OCB_INFO")
endevent

//
// Enables the OCBClient interface
//
event inq : INQ_OCB_START
  call LogMessage("Start Event INQ_OCB_START")

  call OCBStart( TRUE )
   
  call LogMessage("End Event INQ_OCB_START")
endevent

//
// Disables the OCBClient interface
//
event inq : INQ_OCB_STOP
  call LogMessage("Start Event INQ_OCB_STOP")

  call OCBStop( TRUE )

  call LogMessage("End Event INQ_OCB_STOP")
endevent

//
// Permanent claim of OCB 1
//
event inq : INQ_CLAIM_1
  call LogMessage("Start Event INQ_CLAIM_1")

  call OCBClaim( 1, FALSE, TRUE )

  call LogMessage("End Event INQ_CLAIM_1")
endevent

//
// Permanent claim of OCB 2
//
event inq : INQ_CLAIM_2
  call LogMessage("Start Event INQ_CLAIM_2")

  call OCBClaim( 2, FALSE, TRUE )

  call LogMessage("End Event INQ_CLAIM_2")
endevent

//
// Temporary claim of OCB 1 for 1 Transaction
//
event inq : INQ_TEMP_CLAIM_1
  call LogMessage("Start Event INQ_TEMP_CLAIM_1")

  call OCBClaim( 1, TRUE, TRUE )

  call LogMessage("End Event INQ_TEMP_CLAIM_1")
endevent

//
// Temporary claim of OCB 2 for 1 Transaction
//
event inq : INQ_TEMP_CLAIM_2
  call LogMessage("Start Event INQ_TEMP_CLAIM_2")
  
  call OCBClaim( 2, TRUE, TRUE )

  call LogMessage("End Event INQ_TEMP_CLAIM_2")
endevent

//
// Release Current OCB
//
event inq : INQ_RELEASE_CURRENT
  call LogMessage("Start Event INQ_RELEASE_CURRENT")

  call OCBReleaseCurrent()

  call LogMessage("End Event INQ_RELEASE_CURRENT")
endevent

//
// Force Release of OCB 1
//
event inq : INQ_FORCE_RELEASE_1
  call LogMessage("Start Event INQ_FORCE_RELEASE_1")

  call OCBForceRelease( 1 )

  call LogMessage("End Event INQ_FORCE_RELEASE_1")
endevent

//
// Force Release of OCB 2
//
event inq : INQ_FORCE_RELEASE_2
  call LogMessage("Start Event INQ_FORCE_RELEASE_2")

  call OCBForceRelease( 2 )

  call LogMessage("End Event INQ_FORCE_RELEASE_2")
endevent

//
// Sets the send flag to true. This should be used in a macro followed by
// the 'Send' key. This macro should then be linked to touch screens instead
// of directly linking the send key for correct send behavior.
//
event inq : INQ_SET_SEND_FLAG
  call LogMessage("Start Event INQ_SET_SEND_FLAG")

  gv_bSendFlag = 1

  call LogMessage("End Event INQ_SET_SEND_FLAG")
endevent

//
//
//  System Events
//

//
// 
//
event init
   LOG_FILE_ENABLED = 0
   call LogMessage("Start Event init")
   
   gv_bSendFlag      = 0
   gv_bDisplayVoids  = 1
   call OCBStart( FALSE )

   call LogMessage("End Event init")
endevent
//
//
//
event exit
  call LogMessage("Start Event exit")
  
  call OCBStop( FALSE )
  
  call LogMessage("End Event exit")
endevent
//
//
//
event begin_check
  call LogMessage("Start Event begin_check")
  
  if (gv_dllHandle <> 0)
    prompt PLEASE_WAIT_PROMPT      
    dllcall_cdecl gv_dllHandle, OCB_BeginOrder()
  endif
  
  call LogMessage("End Event begin_check")
endevent
//
//
//
event pickup_check

  if (gv_dllHandle <> 0)
    prompt PLEASE_WAIT_PROMPT      
    dllcall_cdecl gv_dllHandle, OCB_BeginOrder()
  endif

endevent
//
// 
//
event trans_cncl

  if (gv_dllHandle <> 0)
    prompt PLEASE_WAIT_PROMPT      
    dllcall_cdecl gv_dllHandle, OCB_CancelOrder()
  endif

endevent
//
// 
//
event srvc_total: *

  if (gv_dllHandle <> 0 AND gv_bSendFlag <> 1)

    prompt PLEASE_WAIT_PROMPT      

    if (gv_IVersion < I_VERSION_4)
        dllcall_cdecl gv_dllHandle, OCB_EndOrder( @TTLDUE )
    else
		call LogMessage("SRVC_TOTAL EndOrder 2")
        // dllcall_cdecl gv_dllHandle, OCB_EndOrder( @TTLDUE, 1 )
		dllcall_cdecl gv_dllHandle, OCB_EndOrder( @TTLDUE, 2 )
    endif

  else
    gv_bSendFlag = 0
  endif

endevent
//
// 
//
event final_tender
   call LogMessage("Start Event FINAL_TENDER")

   var total      : $12
   var i          : N9

   if (gv_dllHandle <> 0)

      for i = 1 to @NUMDTLT
         if ( @DTL_TYPE[i] = "T" )
            total = total + @DTL_TTL[i]
         endif
      endfor

      prompt PLEASE_WAIT_PROMPT      

      if (gv_IVersion < I_VERSION_4)
		call LogMessage("FINAL_TENDER EndOrder < I_VERSION_4")
        dllcall_cdecl gv_dllHandle, OCB_EndOrder( @TTLDUE )
      else
		call LogMessage("FINAL_TENDER EndOrder 2")
        dllcall_cdecl gv_dllHandle, OCB_EndOrder( @TTLDUE, 2 )
      endif


   endif

   call LogMessage("Stop Event FINAL_TENDER")
endevent 
//
// 
//
event dtl_changed

   var i          : N3 = 0
   var nDtlId     : N3
   var bContinue  : N1
   var tax        : $18
   var amountDue  : $18
   var payments   : $18
   var bIsComboSide  : N1

   var serializedDtl: A1024

   if (gv_dllHandle <> 0)

      i = @NUMDTLT
	  call LogCurrentOrder
	  call LogMessage("Start OCB_BeginDtlTransfer")
      dllcall_cdecl gv_dllHandle, OCB_BeginDtlTransfer()
	  call LogMessage("Started OCB_BeginDtlTransfer")
      
      bContinue = 1

      while (bContinue AND i > 0)

         if gv_bDisplayVoids OR NOT( @DTL_IS_VOID[i] AND BIT( @DTL_STATUS[i], 15 ) <> 0 )
               
            bIsComboSide = @DTL_IS_COMBO_MAIN[i] OR @DTL_IS_COMBO_SIDE[i]

            nDtlId = i

			if (@DTL_TYPE[i]<>"I")
			  if (trim(@dtl_name_two[i])<>"")
				if not ((@dtl_is_cond[i] = 1) and (@dtl_is_default_cond[i] = 1))  // remove all default grills from output
					if (gv_IVersion = I_VERSION_1)
					  call LogMessage("Start OCB_TransferDtlItem 1")
					  dllcall_cdecl gv_dllHandle, OCB_TransferDtlItem( @DTL_TYPE[i],    \
																	   nDtlId,          \
																	   @DTL_SEAT[i],    \
																	   @DTL_QTY[i],     \
																	   @dtl_name_two[i],    \
																	   @DTL_TTL[i],     \
																	   @DTL_IS_COND[i], \
																	   bIsComboSide,    \
																	   ref bContinue )

					  call LogMessage("End OCB_TransferDtlItem 1")
					elseif (gv_IVersion = I_VERSION_2)
					  call LogMessage("Start OCB_TransferDtlItem 2")

					  //
					  // Added @DTL_OBJECT[] to the call as the third parameter
					  //
					  dllcall_cdecl gv_dllHandle, OCB_TransferDtlItem( @DTL_TYPE[i],    \
																	   nDtlId,          \
																	   @DTL_OBJECT[i],  \
																	   @DTL_SEAT[i],    \
																	   @DTL_QTY[i],     \
																	   @dtl_name_two[i],    \
																	   @DTL_TTL[i],     \
																	   @DTL_IS_COND[i], \
																	   bIsComboSide,    \
																	   ref bContinue )

					  call LogMessage("End OCB_TransferDtlItem 2")
					elseif (gv_IVersion >= I_VERSION_3)
					  call LogMessage("Start OCB_TransferDtlItem >= 3")

					  call SerializeDetail(i, serializedDtl)

					  dllcall_cdecl gv_dllHandle, OCB_TransferDtlItem( serializedDtl, ref bContinue )
					  call LogMessage("End OCB_TransferDtlItem >=3")

					endif
				endif
			endif
		  endif

         endif
         
         i = i - 1

      endwhile
      
      for i = 1 to 8
         tax = tax + @TAX[i]
      endfor

	  call LogMessage("Start OCB_EndDtlTransfer")
      dllcall_cdecl gv_dllHandle, OCB_EndDtlTransfer( tax, @TTLDUE )
	  call LogMessage("Started OCB_EndDtlTransfer")
      
   endif

endevent
//
// Serializes the detail item into the passes string
//
// -----
// NOTE
// -----
// Exposing DTL_STATUS and DTL_TYPEDEF is not be a good idea for several
// reasons:
//   * it pretty close to the implementation details and managing change will
//     be difficult
//   * lots of information is not in these bit maps (e.g., combo side/meal
//     info), so we need to deal with this somehow.
//
// Instead, we format our own bit mat using the @DTL_* status variables 
// already exposed to SIM.
//
sub SerializeDetail(var i: N9, ref s)

  var dtlFormatID: N9      // A number indicating the format version
  var prefixType: N1
  var isDefaultCond: N1
  var isAutoDiscount: N1
  var isCoupon: N1
  var isOM: N1
  var isOMBase: N1
  var isOMContainer: N1
  var isOMSection: N1
  var isOMSpecialty: N1
  var isOMTopping: N1
  var dtlStatus: A32

  call EvalCapabilities()

  if (SUPPORTS_COM)
    isDefaultCond = @DTL_IS_DEFAULT_COND[i]
    prefixType = @DTL_PREFIX[i]
  endif

  if (SUPPORTS_OM)
    isOM = @DTL_IS_OM[i]
    isOMBase = @DTL_IS_OM_BASE[i]
    isOMContainer = @DTL_IS_OM_CONTAINER[i]
    isOMSection = @DTL_IS_OM_SECTION[i]
    isOMSpecialty = @DTL_IS_OM_SPECIALTY[i]
    isOMTopping = @DTL_IS_OM_TOPPING[i]
  endif

  if (SUPPORTS_DTL_IS_COUPON)
    isCoupon = @DTL_IS_COUPON[i]
  endif

  if (SUPPORTS_DTL_IS_AUTO_DISCOUNT)
    isAutoDiscount = @DTL_IS_AUTO_DISCOUNT[i]
  endif

  // Format the detail status flags
  format dtlStatus as \
    @DTL_HAS_PRINTED[i], \
    isAutoDiscount, \
    @DTL_IS_COMBO[i], \
    @DTL_IS_COMBO_MAIN[i], \
    @DTL_IS_COMBO_PARENT[i], \
    @DTL_IS_COMBO_SIDE[i], \
    @DTL_IS_COND[i], \
    isDefaultCond, \
    isOM, \
    isOMBase, \
    isOMContainer, \
    isOMSection, \
    isOMSpecialty, \
    isOMTopping, \
    @DTL_IS_ON_HOLD[i], \
    @DTL_IS_VOID[i], \
    @DTL_PRTRCPT[i], \
    @DTL_PRTGSTCHK[i], \
    isCoupon 

  // Format the entire detail
  format s, chr(&1C) as \
    dtlFormatID, \
    i, \
    @DTL_TYPE[i], \
    @DTL_OBJECT[i], \
    @DTL_QTY[i], \
    @DTL_TTL[i], \
    trim(@dtl_name_two[i]), \
    trim(@dtl_name_two[i]), \
    @DTL_SEAT[i], \
    @DTL_MAJGRP_OBJNUM[i], \
    @DTL_FAMGRP_OBJNUM[i], \
    @DTL_MLVL[i], \
    @DTL_SLVL[i], \
    @DTL_PLVL[i], \
    @DTL_TAXTYPE[i], \
    @DTL_ORD_DEV_OUTPUT[i], \
    prefixType, \
    dtlStatus

endsub
//
// Creates the DLL file name for the specified version
//
// NOTE: 
// In v2 of the interface we no longer attempt to prefix the file name with a
// path. This changes means that DLLs should be placed in the same folder
// as the OPS.exe file (usually bin). It also eliminates the @WSTYPE check and
// avoid incompatibilities with other MICROS hardware platforms.
//
sub GetDllFileName(var ifaceVersion: N12, ref fn)

  var fileName: A80

  // Set the subPath and fileName base on the interface version
  if (ifaceVersion = MIN_I_VERSION)

    format fileName as "OCBClient.dll"

  else

    format fileName as "OCBClient_v", ifaceVersion, ".dll"

  endif

  // format fn as rootPath, subPath, fileName
  format fn as fileName

endsub
//
// Loads and initializes the OCBClient dll and claims specified OCB device if
// configured. 
//
// _NOTE_
//  Attempts to load the DLL starting with the most current interface version
//  and preceding to to the oldest version of the interface.
//
sub OCBStart( var bDoMessageBox : N1 )

   var dllFileName   : A256
   var responseMsg    : A(MAX_MSG_LEN)
   var nDeviceToClaim : N3
   var iv: N12
 
   if gv_dllHandle = 0

      // Try to load DLL for each known interface version (max to min)
      for iv = MAX_I_VERSION to MIN_I_VERSION step -1

        call GetDllFileName(iv, dllFileName)

        dllload gv_dllHandle, dllFileName

        if (gv_dllHandle)
          gv_dllFileName = dllFileName
          gv_IVersion = iv
          break
        endif

      endfor

      if (gv_dllHandle = 0)

         errormessage "Failed to load OCBClient.dll"

      else

         // Using both @WSID and @WSNAME makes the clientID value unique (the
         // name alone is not guaranteed to be unique)
         var clientID: A32
         format clientID as @WSID, "-", trim(@WSNAME)

         prompt PLEASE_WAIT_PROMPT
         
         dllcall_cdecl gv_dllHandle, OCB_Start( clientID, ref responseMsg, MAX_MSG_LEN, ref nDeviceToClaim )

         if (responseMsg <> "OK")

            errormessage responseMsg

         elseif (nDeviceToClaim <> 0)

            call OCBClaim( nDeviceToClaim, FALSE, FALSE )

         elseif (bDoMessageBox)

            infoMessage "OCB Interface Enabled"

         endif

      endif            

   endif

endsub
//
// Shut down and unload the OCBClient dll
//
sub OCBStop( var bDoMessageBox : N1 )

   if gv_dllHandle <> 0

      prompt PLEASE_WAIT_PROMPT      
      dllcall_cdecl gv_dllHandle, OCB_Stop()
      
      DLLFREE gv_dllHandle
      gv_dllHandle = 0
      
      if bDoMessageBox
         InfoMessage "OCB Interface Disabled"
      endif

   endif

endsub  
//
// Claims the specified device
//
sub OCBClaim( var nDeviceNum : N1, var bTempClaim : N1, var bDoMessageBox : N1 )

   var responseMsg      : A(MAX_MSG_LEN)
   var bDisplayMIPrefix : N1
   
   if (gv_dllHandle <> 0)
      
      prompt PLEASE_WAIT_PROMPT

      dllcall_cdecl gv_dllHandle, OCB_ClaimDevice( nDeviceNum, \
                                                   bTempClaim, \
                                                   ref responseMsg, \
                                                   MAX_MSG_LEN, \
                                                   ref bDisplayMIPrefix, \
                                                   ref gv_bDisplayVoids )

      if (responseMsg <> "OK")
         infomessage responseMsg
      else
         @PREFIX_DTL_NAME = bDisplayMIPrefix

         if not(bTempClaim) and (bDoMessageBox)
            format responseMsg as "OCB ", nDeviceNum, " Claimed"     
            infomessage responseMsg
         endif
      endif
      
   endif

endsub
//
// Forcibly release the specified device
//
sub OCBForceRelease( var nDeviceNum : N1 )

   var responseMsg : A(MAX_MSG_LEN)
   
   if gv_dllHandle <> 0 
      
      prompt PLEASE_WAIT_PROMPT
      dllcall_cdecl gv_dllHandle, OCB_ForceReleaseDevice( nDeviceNum, ref responseMsg, MAX_MSG_LEN )
      
      if responseMsg <> "OK"
         infomessage responseMsg
      else 
         format responseMsg as "OCB ", nDeviceNum, " Released"     
         infomessage responseMsg
      endif
   endif

endsub
//
// Released the current device
//
sub OCBReleaseCurrent()

   var responseMsg : A(MAX_MSG_LEN)
   
   if gv_dllHandle <> 0 
      
      prompt PLEASE_WAIT_PROMPT
      dllcall_cdecl gv_dllHandle, OCB_ReleaseCurrentDevice( ref responseMsg, MAX_MSG_LEN )
      
      if responseMsg <> "OK"
         infomessage responseMsg
      else 
         format responseMsg as "OCB Released"
         infomessage responseMsg
      endif

   endif

endsub
//
// Call routine to set global flags that indicate features/capabilities that
// are supported by OPS.
//
sub EvalCapabilities()

  if (_CAPABILITIES_KNOWN)
    return
  endif

  //
  // Test for @VERSION bug
  //
  var opsVer: A32 = @VERSION
  if (opsVer <> @VERSION) 
    return
  endif
 
  call _evalCapabilitiesInternal(@VERSION)

  _CAPABILITIES_KNOWN = TRUE

endsub
//
// Implements the evaluation of capabilities for the current version of OPS
//
// This routines exist for testing purposes and should not be called directly,
// instead use EvalCapabilities().
//
sub _evalCapabilitiesInternal(var versionString: A32)

  var resVerNum: N9      // Integer value of version (32 for v3.2.x.y)
  var maj: N9      // First value in version quartet
  var min: N9      // Second value in version quartet
  var rel: N9      // Third value in version quartet
  var bld: N9      // Fourth value in version quartet

  // Get version information
  split versionString, ".", maj, min, rel, bld
  resVerNum = (maj * 10) + min 

  // COM stands for Conversational Ordering Mode, it first appears in 
  // RES v4.3; however, the SIM variables were not added until the version
  // tested for below.
  SUPPORTS_COM = (resVerNum > 44) or ( (resVerNum = 44) and (bld >= 1405) )

  SUPPORTS_OM = (resVerNum > 43) or ( (resVerNum = 43) and (bld >= 1216) )

  SUPPORTS_DTL_IS_COUPON = (resVerNum > 43) or ( (resVerNum = 43) and (bld >= 1216) )

  SUPPORTS_DTL_IS_AUTO_DISCOUNT = (resVerNum > 43) or ( (resVerNum = 43) and (bld >= 1216) )

endsub

sub LogMessage(var mess : A8096)
  var Fn              : N9
  var Fname           : A50
  var Line_out        : A8096
  var dateNow         : A8
  var timeNow         : A8

  if LOG_FILE_ENABLED = TRUE
    call CurrentDate(dateNow)
    Format Fname as "PMS_COD_", dateNow, ".log"
    fopen Fn, Fname, Append
    call CurrentTime(timeNow)
    format line_out as timeNow, "    ", mess
    fwriteln fn, line_out
    fclose fn
  endif
endsub

sub CurrentDate(ref dateNow)
  var year  : A10
  var month : A10
  var day   : A10
  
  year = @Year
  month = @Month
  day = @Day
  
  call ZeroPadded(2, year)
  call ZeroPadded(2, month)
  call ZeroPadded(2, day)
  
  Format dateNow as year, month, day  
endsub 

sub CurrentTime(ref timeNow)
  var hour   : A10
  var minute : A10  
  var second : A10
  
  hour = @Hour
  minute = @Minute
  second = @Second
  
  call ZeroPadded(2, hour)
  call ZeroPadded(2, minute)
  call ZeroPadded(2, second)
  
  Format timeNow as hour, minute, second
endsub 

sub ZeroPadded(var fixedLenght: N5, ref number)
  var s : A128
  
  if len(number) > fixedLenght
    s = number
    number = MID(s, len(s) - fixedLenght + 1, fixedLenght)
  else    
    while len(number) < fixedLenght
	  s = number
      Format number as "0", s
    endwhile	  
  endif
endsub 

sub CurrentDateTime(ref DTNow)
  var d: A6
  var t: A6
  
  call CurrentDate(d)
  call CurrentTime(t)
  format DTNow as d, t
endsub

sub LogCurrentOrder
  var i        : N5
  var line     : A1024
  var fn       : N5
  var prefix   : N1
  var dateNow  : A8
  var timeNow  : A8  
  var fileName : A256  
  var prefix_type[6]: A32
    prefix_type[1] = "DEFAULT_PREFIX"
    prefix_type[2] = "NO_PREFIX"
    prefix_type[3] = "PLAIN_PREFIX"
    prefix_type[4] = "EVERYTHING_PREFIX"
    prefix_type[5] = "ADD_PREFIX"
    prefix_type[6] = "SUBSTITUTE_PREFIX"
	
  if LOG_FILE_ENABLED = TRUE
    call CurrentDate(dateNow)
    Format fileName as "CurrentOrder_", dateNow,".log"
    call CurrentTime(timeNow)
    
    fopen fn, fileName, append
    
    fwriteln fn, " "
    format line as "** Current Order Start [Time: ", timeNow, "] [OrderNo: ", @cknum, "] [AmountToPay: ", @TTLDUE, "] [AmountPayed: ", @tndttl, "]**"
    fwriteln fn, line
  
    format line as "  Ordertype = ", @Ordertype, " Order type name = ", @Order_type_name
    fwriteln fn, line
    
    for i = 1 to @NUMDTLT step 1    
  	
      format line as "  i=", i, "  Item name:", @dtl_name_two[i] ," [", @dtl_name_two[i], "]"
      fwriteln fn, line
      
      format line as "    Qty = ", @dtl_qty[i], "    Total = ", @dtl_ttl[i], " [Price level = ", @dtl_plvl[i], "]" 
      fwriteln fn, line
      
      format line as "    Type = ", @dtl_type[i]
      fwriteln fn, line
	  
      format line as "    Autofire Time = ", @dtl_autofire_time[i]
      fwriteln fn, line      
      
      format line as "    Charge tip name = ", @dtl_charge_tip_name[i],"    charge tip amount = ", @dtl_charge_tip_amount[i]
      fwriteln fn, line	
      
      format line as "    Family group sequence number = ", @dtl_famgrp[i] 
      fwriteln fn, line
      
      format line as "    Major group sequence number is  = ", @dtl_majgrp[i] 
      fwriteln fn, line
      
      format line as "    Main menu level  = ", @dtl_mlvl[i] 
      fwriteln fn, line
      
      format line as "    Sub menu level  = ", @dtl_slvl[i] 
      fwriteln fn, line
      
      format line as "    Object number  = ", @dtl_objnum[i] 
      fwriteln fn, line
  	
  	  format line as "    Sequence number of a detail item   = ", @Dtl_Sequence[i] 
      fwriteln fn, line
      
      format line as "    Obect ID  = ", @dtl_object[i] 
      fwriteln fn, line
      
      format line as "    Preset  = ", bit( @Dtl_Typedef[i], 1 )  
      fwriteln fn, line
      
      format line as "    Weighed  = ", bit( @Dtl_Typedef[i], 28 ) 
      fwriteln fn, line
      
      format line as "    Identification value = ", @dtl_Id[i]
      fwriteln fn, line
	  
	  format line as "    Parent detail id = ", @Parent_Dtl_Id[i] 
      fwriteln fn, line
	  
      if ( @dtl_is_combo[i] ) 
        format line as "    Product is part of a combo meal (@dtl_is_combo) = ", @dtl_is_combo[i]
        fwriteln fn, line
      else
        format line as "    Product is not part of a combo meal (@dtl_is_combo) = ", @dtl_is_combo[i]
        fwriteln fn, line
      endif
      
      if ( @dtl_is_combo_main[i] ) 
        format line as "    Product is a main item of a combo meal (@dtl_is_combo_main) = ", @dtl_is_combo_main[i] 
        fwriteln fn, line
      else
        format line as "    Product is not a main item of a combo meal (@dtl_is_combo_main) = ", @dtl_is_combo_main[i] 
        fwriteln fn, line
      endif
      
      if ( @dtl_is_combo_parent[i] ) 
        format line as "    Product is a parent of a combo meal (@dtl_is_combo_parent) = ", @dtl_is_combo_parent[i] 
        fwriteln fn, line
      else
        format line as "    Product is not a parent of a combo meal (@dtl_is_combo_parent) = ", @dtl_is_combo_parent[i] 
        fwriteln fn, line
      endif
      
      if ( @dtl_is_combo_side[i] ) 
        format line as "    Product is a side item of a combo meal (@dtl_is_combo_side) = ", @dtl_is_combo_side[i] 
        fwriteln fn, line
      else
        format line as "    Product is not a side item of a combo meal (@dtl_is_combo_side) = ", @dtl_is_combo_side[i] 
        fwriteln fn, line
      endif
      
      if ( @dtl_is_cond[i] ) 
        format line as "    Product is a condiment of a menu item (@dtl_is_cond) = ", @dtl_is_cond[i] 
        fwriteln fn, line
      else
        format line as "    Product is not a condiment of a menu item (@dtl_is_cond) = ", @dtl_is_cond[i] 
        fwriteln fn, line	  
      endif
      
      if ( @dtl_is_default_cond[i] ) 
        format line as "    Product is the default condiment of a menu item (@dtl_is_default_cond) = ", @dtl_is_default_cond[i] 
        fwriteln fn, line
      else
        format line as "    Product is not the default condiment of a menu item (@dtl_is_default_cond) = ", @dtl_is_default_cond[i] 
        fwriteln fn, line	  
      endif
      
      if ( @dtl_is_void[i] = 1 ) 
        format line as "    Product is void (@dtl_is_void) = ", @dtl_is_void[i] 
      else  
        format line as "    Product is not void (@dtl_is_void) = ", @dtl_is_void[i] 
      endif
      fwriteln fn, line
      
      prefix = @dtl_prefix[i]
      if prefix 
        format line as "    Type by prefix is ", prefix_type[prefix], ", @dtl_prefix = ", prefix 
        fwriteln fn, line
      else	
        format line as "    Type by prefix not found, @dtl_prefix = ", prefix 
        fwriteln fn, line	  
      endif
      
      format line as "    Dining course (@dtl_dining_course) = ", @dtl_dining_course[i], "    Prep time (@dtl_prep_time) = ", @dtl_prep_time[i]
      fwriteln fn, line
      
      format line as "    Which discounts are associated with the item discounts (@Dtl_DSC_ITTL) = ", @Dtl_DSC_ITTL[i]
      fwriteln fn, line
      
      format line as "    Identifies the Subtotal discounts and their associated totals (@Dtl_DSC_STTL) = ", @Dtl_DSC_STTL[i]
      fwriteln fn, line
      
      format line as "    Menu item's major group object number (@DTL_FAMGRP_OBJNUM) = ", @DTL_FAMGRP_OBJNUM[i]
      fwriteln fn, line
      
      format line as "    Family group object number (@DTL_FamGrp_ObjNum) = ", @DTL_FamGrp_ObjNum[i]
      fwriteln fn, line

      format line as "    Automatic discount (@Dtl_is_auto_discount) = ", @Dtl_is_auto_discount[i]
      fwriteln fn, line
	  
      format line as "    Is an Ordering Module menu item (@Dtl_is_om) = ", @Dtl_is_om[i]
      fwriteln fn, line

      format line as "    Is an Ordering Module base menu item (@Dtl_is_om_base) = ", @Dtl_is_om_base[i]
      fwriteln fn, line

      format line as "    Is an Ordering Module menu item container (@Dtl_is_om_container) = ", @Dtl_is_om_container[i]
      fwriteln fn, line

      format line as "    Is an Ordering Module menu item section (@Dtl_is_om_section) = ", @Dtl_is_om_section[i]
      fwriteln fn, line

      format line as "    Is an Ordering Module specialty menu item (@Dtl_is_om_specialty) = ", @Dtl_is_om_specialty[i]
      fwriteln fn, line

      format line as "    Is an Ordering Module topping menu item (@dtl_is_om_topping) = ", @dtl_is_om_topping[i]
      fwriteln fn, line

      format line as "    Is an Ordering Module topping menu item (@dtl_is_om_topping) = ", @dtl_is_om_topping[i]
      fwriteln fn, line
      
    endfor
    
    format line as "** Current Order End **"
    fwriteln fn, line
    
    fclose fn	
  endif

endsub


