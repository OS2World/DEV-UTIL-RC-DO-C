/* E:\PMBUILD\rccdodlg.c produced by vrexx pgm rc-do-c */
/* American Coders Ltd */
/* PO Box 97462 */
/* Raleigh, NC  27462 */
/* (919) 846 - 2014 */
#define INCL_WINBUTTONS
#define INCL_WINSYS
#define INCL_WINFRAMEMGR
#define INCL_WINMENUS
#define INCL_WINENTRYFIELDS
#define INCL_WINMLE
#define INCL_WINDIALOGS
#define INCL_GPI
#define INCL_DOS
#include <os2.h>
#include <stdlib.h>
#include "E:\PMBUILD\rccdo.h"
 /* start char array defines for ENTRY fields */
char sz_entryfield[ 8];
ULONG ul_length_entryfield = 0;
 /* start *char  defines for MLE fields */
char *sz_mle;
ULONG ul_length_mle = 0;
 /* start enum list of check box */
enum   en_check_box {    en_cb_check
                         ,    en_cb_checker2
                         ,    en_cb_Acheck
   }; /* end enum list of check box */
 /* boolean table of all  checkbox each is set to false */
BOOL check_box[3];
ULONG  radio_button[1];  /*boolean table of dialog radio buttons where 1 dialog = 1 radion button */
MRESULT EXPENTRY dlgproc_Open_CH(HWND, ULONG, MPARAM, MPARAM);
enum en_radio_button { en_rb_Open_CH
              }; /* end enum list of radio buttons, one button for each dialog */
 
HAB hab;
HWND  hwndmain, hwndCl;
main(int argc, char *argv)
{
QMSG qmsg;
 HMQ hmq;
 HPS hps;
 hab = WinInitialize(0ul);
 hmq = WinCreateMsgQueue(hab,0ul);
WinDlgBox(HWND_DESKTOP,HWND_DESKTOP,dlgproc_Open_CH,
      0,Open_CH,NULL);
 WinDestroyMsgQueue( hmq );
 WinTerminate( hab );
}

MRESULT EXPENTRY dlgproc_Open_CH(HWND hwnd,ULONG msg,MPARAM mp1,MPARAM mp2)
{
 switch(msg)
 {
   case WM_INITDLG:
           WinSendDlgItemMsg(hwnd,entryfield ,
                 EM_SETTEXTLIMIT, 
                     MPFROM2SHORT( 8,0),NULL);
           WinSetDlgItemText(hwnd,entryfield, sz_entryfield);
             if (ul_length_mle)
                  WinSetDlgItemText(hwnd,mle, sz_mle);
           WinSendDlgItemMsg(hwnd,check ,
                 BM_SETCHECK, 
                     MPFROM2SHORT(check_box[en_cb_check],0),NULL);
           WinSendDlgItemMsg(hwnd,checker2 ,
                 BM_SETCHECK, 
                     MPFROM2SHORT(check_box[en_cb_checker2],0),NULL);
           WinSendDlgItemMsg(hwnd,Acheck ,
                 BM_SETCHECK, 
                     MPFROM2SHORT(check_box[en_cb_Acheck],0),NULL);
        if  (radio_button[0])  /* this radio button is on */
                WinSendDlgItemMsg(hwnd,radio_button[0],
                       BM_SETCHECK, 
                          MPFROM2SHORT(TRUE,0),NULL);
    break;
   case WM_CLOSE:
    break;
   case WM_CONTROL:
     switch ( SHORT1FROMMP(mp1) )
        {
          case check: /* CHECKBOX */
             if (check_box[en_cb_check])
                  check_box[en_cb_check] = FALSE;
             else    check_box[en_cb_check] = TRUE;
             WinSendDlgItemMsg(hwnd,check ,
                   BM_SETCHECK, 
                       MPFROM2SHORT(check_box[en_cb_check],0),NULL);
              break;
          case entryfield: /* ENTRYFIELD */
               if (SHORT2FROMMP(mp1) == EN_KILLFOCUS)
                   WinQueryDlgItemText(hwnd,entryfield, 8,sz_entryfield);
              break;
          case horizontal: /* CONTROL */
              break;
          case mle: /* MLE */
               if (SHORT2FROMMP(mp1) == MLN_KILLFOCUS) {
                  ul_length_mle =
                       WinQueryDlgItemTextLength(hwnd,mle);
                  if (ul_length_mle) {
                       if (sz_mle)  
                         free (sz_mle);
                     sz_mle= malloc(++ul_length_mle);
                     WinQueryDlgItemText(hwnd,mle,ul_length_mle ,sz_mle);
                      }
                   else {    /* if there was something there; it is gone now */
                       if (sz_mle)  
                         free (sz_mle);
                        ul_length_mle = 0;
                      }
                   }
              break;
          case vertical: /* CONTROL */
              break;
          case radio_2: /* RADIOBUTTON */
             WinSendDlgItemMsg(hwnd,radio_button[0],
                   BM_SETCHECK, 
                       MPFROM2SHORT(FALSE,0),NULL);
                   radio_button[0] =  radio_2;
              WinSendDlgItemMsg(hwnd,radio_button[0],
                   BM_SETCHECK, 
                       MPFROM2SHORT(TRUE,0),NULL);
              break;
          case checker2: /* CHECKBOX */
             if (check_box[en_cb_checker2])
                  check_box[en_cb_checker2] = FALSE;
             else    check_box[en_cb_checker2] = TRUE;
             WinSendDlgItemMsg(hwnd,checker2 ,
                   BM_SETCHECK, 
                       MPFROM2SHORT(check_box[en_cb_checker2],0),NULL);
              break;
          case Radio_ID: /* RADIOBUTTON */
             WinSendDlgItemMsg(hwnd,radio_button[0],
                   BM_SETCHECK, 
                       MPFROM2SHORT(FALSE,0),NULL);
                   radio_button[0] =  Radio_ID;
              WinSendDlgItemMsg(hwnd,radio_button[0],
                   BM_SETCHECK, 
                       MPFROM2SHORT(TRUE,0),NULL);
              break;
          }
    break;
   case WM_COMMAND:
     switch ( SHORT1FROMMP(mp1) )
        {
          case check: /* CHECKBOX */
              break;
          case combolistbox: /* COMBOBOX */
              break;
          case entryfield: /* ENTRYFIELD */
              break;
          case listbox: /* LISTBOX */
              break;
          case mle: /* MLE */
              break;
          case push: /* PUSHBUTTON */
                WinDismissDlg(hwnd,0);
              break;
          case text: /* LTEXT */
              break;
          case radio_2: /* RADIOBUTTON */
              break;
          case checker2: /* CHECKBOX */
              break;
          case Acheck: /* AUTOCHECKBOX */
             check_box[en_cb_Acheck] = WinQueryButtonCheckstate(hwnd,Acheck);
              break;
          case AutoRadio: /* AUTORADIOBUTTON */
              if (WinQueryButtonCheckstate(hwnd,AutoRadio) )
                   radio_button[0] =  AutoRadio;
              break;
          case Radio_ID: /* RADIOBUTTON */
              break;
      }
   default:
      return(WinDefDlgProc(hwnd,msg,mp1,mp2));
      break;
  }
  return (FALSE);
}

