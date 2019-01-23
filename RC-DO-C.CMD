/* RC-DO-C.CMD */
/*Copyright 1992-93 American Coders LTD  Raleigh NC USA*/
/*All rights reserved*/
/* release 02 - define radio and push button logical arrays */
/* release 03 - define entry field and mle char arrays */
/*                     add dialog on exit warning */
/* release 04 -  added win/dlg names to proc names */
/*                     added no-window/start-dialog from main logic */
say 'Before use; read RC-DO-C.LIC and RC-DO-C.TXT'
say 'Copyright 1992-93 American Coders LTD  Raleigh NC USA'
say 'All rights reserved'

signal on failure name CLEANUP
signal on halt name CLEANUP
signal on syntax name CLEANUP

'@echo off'
call RxFuncAdd 'VInit', 'VREXX', 'VINIT'
initcode = VInit()
if initcode = 'ERROR' then signal CLEANUP


arg ffile
say ffile
file = ffile
if ffile = '' then ffile = '*.rc'
else call findfile
filec = ''
item.dlgcnt = 0
item.wincnt = 0
item.filework = 0
item.dcnt = 0
item.wcnt = 0
item.qcnt = 0
item.inc = ''
flist.1 = 'Start Win/Dlg'
flist.2 = 'End Win/Dlg'
flist.3 = 'End with Warning'
flist.4 = 'Find A File Dialog'
flist.5 = 'Add Help Logic'
flist.0 = 5

slist.0 = 6
slist.1  = 'Find RC/DLG File'
slist.2 =  'Parse The File'
slist.3  = 'Add Controls'
slist.4  = 'Save Parsed File'
slist.5  = 'Load a Parsed file'
slist.6  = 'Build a C File'
slist.vstring = slist.1
 do forever
  if ffile \=  ''  then msgfile = ffile 
  else msgfile = 'First, find a RC file'
  call VDialogPos 50, 45
  rc = VRadioBox( msgfile, slist, 3)
  if rc =  CANCEL then leave
  if slist.vstring = slist.1 then call findfile
  if slist.vstring = slist.2  then call parsefile file 
  if slist.vstring = slist.3 then call addcontrols
  if slist.vstring = slist.4 then call savecontrols
  if slist.vstring = slist.5 then call loadcontrols
  if slist.vstring = slist.6 then do
    if cfile() = CANCEL then iterate
    call buildc
  end
  if file \= '' then do
       lp = lastpos('\',file)+1
       rfile = substr(file,lp,length(file))
  end    
end
call Cleanup
return

addcontrols: procedure expose file win. dlg. item. flist.
if item.wincnt = 0 & item.dlgcnt = 0 then return
do forever
   j = 0
   do i = 1 to item.wincnt
     j = j + 1
     list.j = win.nm.i
   end
   do i = 1 to item.dlgcnt
      j = j + 1
      list.j = dlg.nm.i
   end
   list.vstring = list.1
   list.0 = j
   call VDialogPos 25, 90
   rc = VListBox('Pick A Win/Dlg', list, 25,8,3)
   if rc =  CANCEL then leave
   do i = 1  to j
      if list.i = list.vstring then savef = i
   end
   do forever
   if savef <= item.wincnt then do
      j = 0
      do k = win.first.savef to win.last.savef
         j = j + 1
         list.j = item.nm.k
         pos.j = k
      end
   end
   else do
     j = 0
     l = savef - item.wincnt
     do k = dlg.first.l to dlg.last.l
         j = j + 1
         list.j = item.nm.k
         pos.j = k
     end
   end
    list.0 = j
    list.vstring = list.1
    call VDialogPos 50, 70
    rc = VListBox('Pick A Control', list, 28,12,3)
    if rc = CANCEL then leave
    do l = 1 to j
      if list.vstring = list.l then do
         m = pos.l
         leave
      end
     end     
     call VDialogPos 75, 50
     rc = VRadioBox('Pick A Function', flist, 3)
     if rc =  CANCEL then iterate
     if flist.vstring \= flist.1 then do
       item.fn.m = flist.vstring
       if flist.vstring = flist.4 then item.filework = 1
       iterate
     end
     j = 0
     l = 0
     do i = 1 to item.wincnt
        l = l + 1
        if l = savef then iterate
        j = j + 1
        list.j = win.nm.i
     end
     do i = 1 to item.dlgcnt
       l = l + 1
       if l = savef then iterate
       j = j + 1
       list.j = dlg.nm.i
     end
     list.vstring = list.1
     list.0 = j
     call VDialogPos 100, 25
     rc = VListBox('Pick A Starting Win/Dlg', list, 25,8,3)
     if rc =  CANCEL then leave
     item.fn.m = list.vstring
   end
end
j = item.dlgcnt
j = dlg.last.j
do i = 1 to j
   if item.fn.i \= '' then say i item.nm.i item.fn.i
end
return 

findfile: procedure expose file ffile
call VDialogPos 15, 45
lp = lastpos('.',ffile)
if lp > 0  then ffile = '*' || substr(ffile,lp,length(ffile)-lp+1)
else ffile = '*.rc'
button = VFileBox('Pick (.RC or .DLG) file...', ffile, ifile)
if button = OK then file = ifile.vstring
lp = lastpos('\',file)
if lp = 0 then ffile = file
else ffile=substr(file,lp+1,length(file)-lp)
return

cfile: procedure expose filec ffile
call VDialogPos 15, 45
lp = lastpos('\',ffile)
if lp = 0 then cffile = '\*.c'
else cffile=substr(ffile,1,lp)'*.c'
button = VFileBox('Load to a .c file...', cffile, ifile)
if button = OK then filec = ifile.vstring
return button

parsefile: procedure expose file win. dlg. item.
item.dcnt = 0
item.wcnt = 0
item.qcnt = 0
item.filework = 0
item.inc = ''
item.pointer = 0
item.accel    = 0
item.icon      = 0
call buildqueue file
dotype = 'win'
inln = ''
wcnt = 0
dcnt = 0
icnt = 0
depth = 0
do while queued() > 0
  parse pull inln
  if inln = '{' then do 
   depth = depth + 1
    iterate
    end
   if inln = 'BEGIN' then do 
   depth = depth + 1
    iterate
    end
  if inln = '}' then do 
   depth = depth - 1
    iterate
    end
  if inln = 'END' then do 
   depth = depth - 1
    iterate
    end
  parse var inln type value','idn','therest
   parse var idn idn1 therest1
  if idn1 = '-1' then iterate /* no assignment */
  if type = '#include' then do
     item.inc = value
     iterate
     end
  if pos(',',type) > 0 then iterate /* continutation line */
  if pos('_',type) > 0 then iterate           /*   probably a pm option */
  if type = 'NOT' then iterate /* pm word */
  if pos('|',type) > 0 then iterate /* continutation line */
  if type = GROUPBOX then iterate /* let's not do this type either */
  if type = POINTER then do
         item.pointer = 1
         iterate
      end
  if type = LISTBOX then idn = value
  if datatype(idn) = NUM then iterate /* no name from .h file */
  if pos('""',idn) > 0 then iterate /* empty value */
  if type = MENU then do
     if wcnt > 0 then   win.last.wcnt = icnt
     wcnt = wcnt + 1
     win.first.wcnt = icnt  + 1
     parse var value name therest2
     win.nm.wcnt = name
     say Window function is name
     dotype = 'win'
  end
  else  if type = DIALOG then iterate
  else  if type = DLGTEMPLATE then do
     if dotype = 'win'  & wcnt > 0 then win.last.wcnt = icnt
     if dcnt > 0 then dlg.last.dcnt = icnt
     dcnt = dcnt + 1
     dlg.first.dcnt = icnt + 1
     parse var value name therest
     dlg.nm.dcnt = name
     say Dialog function is name
     dotype = 'dlg'
   end
   else  do
     icnt = icnt + 1
     item.typ.icnt = strip(type,b)
     item.nm.icnt =  strip(idn,b)
     parse var therest x ',' y ',' xlen ',' ylen ',' therest4
     item.sz.icnt = ylen
     item.fn.icnt = ''
    end
end
if dotype = 'win' then win.last.wcnt = icnt
else dlg.last.dcnt = icnt
if  depth \= 0 then say "Depth error "
item.wincnt = wcnt
item.dlgcnt = dcnt
item.itemcnt = icnt
say windows found is item.wincnt
say dialogs found is item.dlgcnt
say items found is item.itemcnt
return 

buildc: procedure expose item. win. dlg. flist. filec
queue '/* 'filec' produced by vrexx pgm rc-do-c */'
queue '/* American Coders Ltd */'
queue '/* PO Box 97462 */'
queue '/* Raleigh, NC  27462 */'
queue '/* (919) 846 - 2014 */'
queue '#define INCL_WINBUTTONS'
queue '#define INCL_WINSYS'
queue '#define INCL_WINFRAMEMGR'
queue '#define INCL_WINMENUS'
queue '#define INCL_WINENTRYFIELDS'
queue '#define INCL_WINMLE'
queue '#define INCL_WINDIALOGS'
if item.filework = 1 then do
  queue '#define INCL_WINSTDFILE  /* Window Standard File Functions       */'
end
queue '#define INCL_GPI'
queue '#define INCL_DOS'
queue '#include <os2.h>'
queue '#include <stdlib.h>'
if item.inc \= '' then queue '#include 'item.inc
else queue '#include "'substr(filec,1,length(filec)-1)||'h"'
do i = 1 to item.wincnt
     queue 'MRESULT EXPENTRY winproc_'win.nm.i'(HWND, ULONG, MPARAM, MPARAM);'
end
foundone = 0
do i = 1 to item.dlgcnt
 do j = dlg.first.i to dlg.last.i
 if pos('ENTRYFIELD',item.typ.j) = 0 then iterate
  if foundone = 0 then
      queue ' /* start char array defines for ENTRY fields */'
      queue 'char sz_' || item.nm.j || '[' || item.sz.j || '];'
      queue 'ULONG ul_length_' || item.nm.j || ' = 0;'
  foundone = 1
 end
end
foundone = 0
do i = 1 to item.dlgcnt
 do j = dlg.first.i to dlg.last.i
 if pos('MLE',item.typ.j) = 0 then iterate
  if foundone = 0 then    queue ' /* start *char  defines for MLE fields */'
  queue 'char *sz_'  || item.nm.j || ';'
  queue 'ULONG ul_length_' || item.nm.j || ' = 0;'
  foundone = 1
 end
end
foundone = 0
do i = 1 to item.dlgcnt
 do j = dlg.first.i to dlg.last.i
  if pos('CHECKBOX',item.typ.j) = 0 then iterate
  if foundone = 0 then do
      queue ' /* start enum list of check box */'
      queue 'enum   en_check_box {    en_cb_' || item.nm.j
       foundone = 1
  end
  else  do
          queue '                         ,    en_cb_' || item.nm.j
           foundone = foundone + 1
        end
  end
end

if foundone >0 then do 
    queue '   }; /* end enum list of check box */'
    queue ' /* boolean table of all  checkbox each is set to false */'
    queue 'BOOL check_box['foundone'];'
end
if item.dlgcnt > 0  then queue 'ULONG  radio_button['item.dlgcnt'];  /*boolean table of dialog radio buttons where 1 dialog = 1 radion button */'
do i = 1 to item.dlgcnt
   queue 'MRESULT EXPENTRY dlgproc_'dlg.nm.i'(HWND, ULONG, MPARAM, MPARAM);'
end
do i = 1 to item.dlgcnt
    if i = 1  then   queue 'enum en_radio_button { en_rb_' || dlg.nm.i
    else queue '                                          ,  en_rb_' || dlg.nm.i
end
if item.dlgcnt > 0 then queue '              }; /* end enum list of radio buttons, one button for each dialog */'
queue ' '
if item.filework = 1 then do
queue '   FILEDLG pfdFiledlg;      /* File dialog info structure           */'
queue '   char pszFileTitle[10] = "Open File"; /* Title of File dialog              */'
queue '   char pszFullFile[CCHMAXPATH] = "*.*";/* File filter string       */'
queue ' '
end
queue 'HAB hab;'
queue 'HWND  hwndmain, hwndCl;'
queue 'main(int argc, char *argv)'
queue '{'
queue 'QMSG qmsg;'
queue ' HMQ hmq;'
queue ' HPS hps;'
if item.wincnt > 0 then do
  queue ' ULONG fcfData = FCF_TITLEBAR | FCF_SYSMENU | FCF_MENU |'
  if item.pointer = 1 then queue '          FCF_ICON |'
  if item.accel    = 1 then queue '          FCF_ACCELTABLE |'
  queue '           FCF_SIZEBORDER | FCF_MINMAX  | FCF_SYSMODAL |'
  queue '           FCF_SHELLPOSITION  | FCF_TASKLIST;'
  queue ' '
end
if item.filework = 1 then do
queue 'memset(&pfdFiledlg, 0, sizeof(FILEDLG));'
queue ' pfdFiledlg.cbSize = sizeof(FILEDLG); '
queue ' pfdFiledlg.fl = FDS_HELPBUTTON | FDS_CENTER | FDS_OPEN_DIALOG;'
queue ' pfdFiledlg.pszTitle = pszFileTitle;      /* Dialog title string      */'
queue ' strcpy(pfdFiledlg.szFullFile, pszFullFile); /* Initial path,    file name or file filter       */'
queue ' '
end
queue ' hab = WinInitialize(0ul);'
queue ' hmq = WinCreateMsgQueue(hab,0ul);'
if item.wincnt > 0 then do
  queue ' WinRegisterClass(hab ,"'win.nm.1'",winproc_'win.nm.1',CS_SIZEREDRAW ,0);'
  queue ' hwndmain = WinCreateStdWindow(HWND_DESKTOP, WS_VISIBLE,'
  queue '   &fcfData,"'win.nm.1'","'win.nm.1'",'
  queue '   0l,(HMODULE)NULL,'win.nm.1',&hwndCl);'
  queue ' while ( WinGetMsg(hab,&qmsg, 0ul,0ul,0ul))'
  queue '    WinDispatchMsg( hab, &qmsg );'
  queue ' WinDestroyWindow(hwndCl);'
 end
else do
  queue 'WinDlgBox(HWND_DESKTOP,HWND_DESKTOP,dlgproc_'dlg.nm.1','
  queue '      0,'dlg.nm.1',NULL);'
 end
queue ' WinDestroyMsgQueue( hmq );'
queue ' WinTerminate( hab );'
queue '}'
queue ''
do i = 1 to item.wincnt
queue 'MRESULT EXPENTRY winproc_'win.nm.i'(HWND hwnd,ULONG msg,MPARAM mp1,MPARAM mp2)'
queue ' {'
queue '   ULONG rc;'
queue '   HPS hps;'
queue '   RECTL rectl;'
queue '   switch(msg)'
queue '     {'
queue '    case WM_COMMAND:'
queue '       switch (SHORT1FROMMP(mp1))'
queue '           { /* menu pulldowns and choices*/'
do j = win.first.i to win.last.i
   if item.typ.j = DLGINCLUDE then iterate
   if item.typ.j \= pointer & item.type.j \= dlginclude then do
     queue '       case ' strip(item.nm.j)': /* 'item.typ.j' */'
   if item.fn.j = flist.2 then,
     queue '        WinPostMsg(hwnd,WM_QUIT,0l,0l);'
   else  if item.fn.j = flist.3 then do
     queue '        if (MBID_YES  =='
     queue '            WinMessageBox('
     queue '                HWND_DESKTOP, hwnd,'
     queue '                   "Window Will Close\nDo You Want To?",'
     queue '                    "Close With Warning",0,'
     queue '                    MB_YESNO|MB_DEFBUTTON2|MB_ICONQUESTION|MB_MOVEABLE))'
     queue '                            WinPostMsg(hwnd,WM_QUIT,0l,0l);'
     end
   else  if item.fn.j = flist.4 then do
       queue '         WinFileDlg(HWND_DESKTOP, hwndmain, &pfdFiledlg);'
       queue '          return FALSE;'
     end
   else  if item.fn.j = flist.5 then,
      queue '      /* no help yet */'
   else if item.fn.j \= '' then do
        do l = 1 to item.wincnt
           if item.fn.j = win.nm.l  then  do
             queue '         WinRegisterClass(hab ,"'win.nm.1 '" ,(PFNWP)winproc_'win.nm.1' ,CS_SIZEREDRAW ,0ul);'
             queue '          hwnd1 = WinCreateStdWindow(HWND_DESKTOP, WS_VISIBLE,'
             queue '           &fcfData,"'win.nm.1 '","'win.nm.1 ' ",'
             queue '             0ul,0ul,'win.nm.1 ',(PHWND)&hwndcl);'
             iterate                                                                

           end
         end
         do l = 1 to item.dlgcnt
           if item.fn.j = dlg.nm.l  then  do
             queue '              WinDlgBox(HWND_DESKTOP',
                ',hwndmain,dlgproc_'dlg.nm.l',(HMODULE)0,'dlg.nm.l',NULL);'
              queue '              return FALSE;'
              iterate
             end
          end
     end
     queue '         break;'
   end
end
queue '      }'
queue '    break;'
queue '   case WM_CONTROL:'
queue '    break;'
queue '   case WM_CREATE:'
queue '    break;'
queue '   case WM_PAINT:'
queue '    hps = WinBeginPaint(hwnd,0ul,0ul);'
queue '    WinQueryWindowRect(hwnd,&rectl);'
queue '    WinFillRect(hps,&rectl,CLR_BLUE);'
queue '    WinEndPaint(hps);'
queue '    return(FALSE);'
queue '    break;'
queue '    }'
queue ' return(WinDefWindowProc(hwnd,msg,mp1,mp2));'
queue '}'
queue ''
end
do i = 1 to item.dlgcnt
queue 'MRESULT EXPENTRY dlgproc_'dlg.nm.i'(HWND hwnd,ULONG msg,MPARAM mp1,MPARAM mp2)'
queue '{'
queue ' switch(msg)'
queue ' {'
queue '   case WM_INITDLG:'
do j = dlg.first.i to dlg.last.i
  if pos('ENTRYFIELD',item.typ.j) > 0 then do
         queue '           WinSendDlgItemMsg(hwnd,'item.nm.j ','
         queue '                 EM_SETTEXTLIMIT, '
         queue '                     MPFROM2SHORT(' || item.sz.j || ',0),NULL);'
         queue '           WinSetDlgItemText(hwnd,' || item.nm.j || ', sz_' || item.nm.j || ');'
     end  /* Do */
end
do j = dlg.first.i to dlg.last.i
 if pos('MLE',item.typ.j) = 0 then iterate
   queue '             if (ul_length_' || item.nm.j || ')'
   queue '                  WinSetDlgItemText(hwnd,' || item.nm.j || ', sz_' || item.nm.j || ');'
end
foundone = 0
 do j = dlg.first.i to dlg.last.i
  if pos('CHECKBOX',item.typ.j) > 0 then do
         queue '           WinSendDlgItemMsg(hwnd,'item.nm.j ','
          queue '                 BM_SETCHECK, '
          queue '                     MPFROM2SHORT(check_box[en_cb_' || item.nm.j || '],0),NULL);'
     end  /* Do */
end
queue '        if  (radio_button[' || i-1 || '])  /* this radio button is on */'
queue '                WinSendDlgItemMsg(hwnd,radio_button[' || i-1 || '],'
queue '                       BM_SETCHECK, '
queue '                          MPFROM2SHORT(TRUE,0),NULL);'
queue '    break;'
queue '   case WM_CLOSE:'
queue '    break;'
queue '   case WM_CONTROL:'
queue '     switch ( SHORT1FROMMP(mp1) )'
queue '        {'
do j = dlg.first.i to dlg.last.i
   if item.typ.j = CONTROL then do
      queue '          case' strip(item.nm.j,b)': /* 'item.typ.j '*/'
      if item.fn.j = flist.2 then     queue '                WinDismissDlg(hwnd,0);'
      else  if item.fn.j = flist.3 then do
        queue '                if (MBID_YES  !='
        queue '                    WinMessageBox('
        queue '                        HWND_DESKTOP, hwnd,'
        queue '                           "Dialog Will Close\nDo You Want To?",'
        queue '                            "Close With Warning",0,'
        queue '                            MB_YESNO|MB_DEFBUTTON2|MB_ICONQUESTION|MB_MOVEABLE))'
        queue '                                return(FALSE);'
        queue '                         WinDismissDlg(hwnd,0);'
       end
     else   if item.fn.j = flist.4 then     queue '                WinFileDlg(HWND_DESKTOP, hwndmain, &pfdFiledlg);'
     else  if item.fn.j = flist.5 then       queue '      /* no help yet */'
     else if item.fn.j \= '' then do
       do l = 1 to item.wincnt
             if item.fn.j = win.nm.l  then  do
               queue '               WinRegisterClass(hab ,"'win.nm.1 '" ,(PFNWP)winproc_'win.nm.1' ,CS_SIZEREDRAW ,0ul);'
               queue '                hwnd1 = WinCreateStdWindow(HWND_DESKTOP, WS_VISIBLE,'
               queue '                &fcfData,"'win.nm.1 '","'win.nm.1 ' ",'
               queue '                  0ul,0ul,'win.nm.1 ',(PHWND)&hwndcl);'
               iterate
            end
         end
       do l = 1 to item.dlgcnt
           if item.fn.j = dlg.nm.l  then  do
             queue '                 WinDlgBox(HWND_DESKTOP,hwnd,dlgproc_'dlg.nm.l',(HMODULE)0,'dlg.nm.l',NULL);'
             queue '                  return FALSE;'
              iterate
           end
       end
     end
     queue '              break;'
     end /* typ.h = CONTROL */
else do
     if  'CHECKBOX' = item.typ.j  then do
          queue '          case' strip(item.nm.j,b)': /* 'item.typ.j '*/'
          queue '             if (check_box[en_cb_' || item.nm.j || '])'
          queue '                  check_box[en_cb_' || item.nm.j || '] = FALSE;'
          queue '             else    check_box[en_cb_' || item.nm.j || '] = TRUE;'
          queue '             WinSendDlgItemMsg(hwnd,'item.nm.j ','
          queue '                   BM_SETCHECK, '
          queue '                       MPFROM2SHORT(check_box[en_cb_' || item.nm.j || '],0),NULL);'
          queue '              break;'
       end
     if 'RADIOBUTTON' = item.typ.j  then do
          queue '          case' strip(item.nm.j,b)': /* 'item.typ.j '*/'
          queue '             WinSendDlgItemMsg(hwnd,radio_button[' || i-1 || '],'
          queue '                   BM_SETCHECK, '
          queue '                       MPFROM2SHORT(FALSE,0),NULL);'
          queue '                   radio_button[' || i-1 || '] = ' item.nm.j || ';'
          queue '              WinSendDlgItemMsg(hwnd,radio_button[' || i-1 || '],'
          queue '                   BM_SETCHECK, '
          queue '                       MPFROM2SHORT(TRUE,0),NULL);'
          queue '              break;'
      end
     if  'ENTRYFIELD' = item.typ.j then do
          queue '          case' strip(item.nm.j,b)': /* 'item.typ.j '*/'
          queue '               if (SHORT2FROMMP(mp1) == EN_KILLFOCUS)'
          queue '                   WinQueryDlgItemText(hwnd,' || item.nm.j || ',' || item.sz.j || ',sz_' || item.nm.j || ');'
          queue '              break;'
     end 
    if 'MLE' = item.typ.j  then do
          queue '          case' strip(item.nm.j,b)': /* 'item.typ.j '*/'
          queue '               if (SHORT2FROMMP(mp1) == MLN_KILLFOCUS) {'
          queue '                  ul_length_' || item.nm.j || ' ='
          queue '                       WinQueryDlgItemTextLength(hwnd,' || item.nm.j || ');'
          queue '                  if (ul_length_' || item.nm.j || ') {'
          queue '                       if (sz_' || item.nm.j || ')  '
          queue '                         free (sz_' || item.nm.j || ');'
          queue '                     sz_' || item.nm.j || '= malloc(++ul_length_' || item.nm.j || ');'
          queue '                     WinQueryDlgItemText(hwnd,' || item.nm.j || ',ul_length_' || item.nm.j || ' ,sz_' || item.nm.j || ');'
          queue '                      }'
          queue '                   else {    /* if there was something there; it is gone now */'
          queue '                       if (sz_' || item.nm.j || ')  '
          queue '                         free (sz_' || item.nm.j || ');'
          queue '                        ul_length_' || item.nm.j || ' = 0;'
          queue '                      }'
          queue '                   }'
          queue '              break;'
     end
  end /* else do */
end /* do j = */
queue '          }'
queue '    break;'
queue '   case WM_COMMAND:'
queue '     switch ( SHORT1FROMMP(mp1) )'
queue '        {'
do j = dlg.first.i to dlg.last.i
   if item.typ.j \= POINTER & item.typ.j \= DLGINCLUDE & item.typ.j \= CONTROL then do
     queue '          case' strip(item.nm.j,b)': /* 'item.typ.j '*/'
     if item.fn.j = flist.2 then,
     queue '                WinDismissDlg(hwnd,0);'
     else  if item.fn.j = flist.3 then do
     queue '                if (MBID_YES  !='
     queue '                    WinMessageBox('
     queue '                        HWND_DESKTOP, hwnd,'
     queue '                           "Dialog Will Close\nDo You Want To?",'
     queue '                            "Close With Warning",0,'
     queue '                             MB_YESNO|MB_DEFBUTTON2|MB_ICONQUESTION|MB_MOVEABLE))'
     queue '                               return(FALSE);'
     queue '                 WinDismissDlg(hwnd,0);'
     end
     else if item.fn.j = flist.4 then,
     queue '                WinFileDlg(HWND_DESKTOP, hwndmain, &pfdFiledlg);'
     else  if item.fn.j = flist.5 then,
     queue '      /* no help yet */'
     else if item.fn.j \= '' then do
       do l = 1 to item.wincnt
        if item.fn.j = win.nm.l  then  do
         queue '               WinRegisterClass(hab ,"'win.nm.1 '" ,(PFNWP)winproc_'win.nm.1' ,CS_SIZEREDRAW ,0ul);'
         queue '                hwnd1 = WinCreateStdWindow(HWND_DESKTOP, WS_VISIBLE,'
         queue '                &fcfData,"'win.nm.1 '","'win.nm.1 ' ",'
         queue '                  0ul,0ul,'win.nm.1 ',(PHWND)&hwndcl);'
         iterate
         end
       end
        do l = 1 to item.dlgcnt
        if item.fn.j = dlg.nm.l  then  do
          queue '                 WinDlgBox(HWND_DESKTOP',
             ',hwnd,dlgproc_'dlg.nm.l',(HMODULE)0,'dlg.nm.l',NULL);'
          queue '                  return FALSE;'
           iterate
           end
       end
      end
      else do
            if  'AUTOCHECKBOX' = item.typ.j  then,
                  queue '             check_box[en_cb_' || item.nm.j || '] = WinQueryButtonCheckstate(hwnd,'item.nm.j');'
            if 'AUTORADIOBUTTON' = item.typ.j  then do
                 queue '              if (WinQueryButtonCheckstate(hwnd,'item.nm.j') )'
                 queue '                   radio_button[' || i-1 || '] = ' item.nm.j || ';'
                end
         end
       queue '              break;'
    end
   end
queue '      }'
queue '   default:'
queue '      return(WinDefDlgProc(hwnd,msg,mp1,mp2));'
queue '      break;'
queue '  }'
queue '  return (FALSE);'
queue '}'
queue ''
end
'del ' filec
say stream(filec, 'c',' OPEN')
do queued()
parse pull cline
call lineout filec, cline
end /* do */
say stream(filec,'c','CLOSE')
return

savecontrols: procedure expose item. win. dlg. ffile cfile
call VDialogPos 15, 45
lp = lastpos('\',ffile)
if lp = 0 then cffile = '\*.rcc'
else cffile=substr(ffile,1,lp)'*.rcc'
button = VFileBox('Save to a .rcc file...', cffile, ifile)
if button = CANCEL then return
rfile = ifile.vstring
' del ' rfile
say stream(rfile, 'c',' OPEN write')
outstring =  ffile','filec','item.wincnt','item.dlgcnt','item.filework
call lineout rfile, outstring, 1
do i = 1 to item.wincnt
    outstring = win.nm.i','win.first.i','win.last.i
    call lineout rfile, outstring
    do j = win.first.i to win.last.i
        outstring = item.nm.j','item.typ.j','item.sz.j','item.fn.j
        call lineout rfile, outstring
     end
end
do i = 1 to item.dlgcnt
      outstring =  dlg.nm.i ','dlg.first.i','dlg.last.i
      call lineout rfile, outstring
      do j = dlg.first.i to dlg.last.i
        outstring = item.nm.j','item.typ.j','item.sz.j','item.fn.j
        call lineout rfile,  outstring 
      end
end
call lineout rfile, item.inc
say stream(rfile,'c','CLOSE')
return

loadcontrols: procedure expose item. win. dlg. ffile filec
call VDialogPos 15, 45
lp = lastpos('\',ffile)
if lp = 0 then cffile = '\*.rcc'
else cffile=substr(file,1,lp)'*.rcc'
button = VFileBox('Load from a .rcc file...', cffile, ifile)
if button = CANCEL then return
rfile = ifile.vstring
say stream(rfile, 'c','OPEN')
parse value linein(rfile) with ffile','filec','item.wincnt','item.dlgcnt','item.filework
do i = 1 to item.wincnt
    parse value linein(rfile) with win.nm.i','win.first.i','win.last.i
    do j = win.first.i to win.last.i
       parse value linein(rfile) with item.nm.j','item.sz.j','item.typ.j','item.fn.j
    end
end
do i = 1 to item.dlgcnt
    parse value linein(rfile) with dlg.nm.i','dlg.first.i','dlg.last.i
    do j = dlg.first.i to dlg.last.i
       parse value linein(rfile) with item.nm.j','item.sz.j','item.typ.j','item.fn.j
    end
end
parse value linein(rfile) with item.inc ','
say stream(rfile,'c','CLOSE')
return


buildqueue: procedure 
arg file
inln = ''
linec = 0
say file
tabchar = D2C(9);
linein(file,1,0)
do while lines(file) > 0
   linec = linec + 1
   inl = linein(file)
   l = length(inl)
   if l < 2 then iterate /* too short anyways */
   do forever
    tab = pos(tabchar,inl);
    if  tab = 0 then leave
    if tab = 1 then inl = ' ' || substr(inl,2,l)
    else if tabl = l then inl = substr(inl,1,l-1) || ' '
    else inl = substr(inl,1,tab-1) || " " || substr(inl,tab+1,l)
   end
   inln = inln || strip(inl,b)
   l = length(inln)
   if l = 0 then iterate
   if substr(inln,1,2) = '/*' then do
     inln = ''
     iterate
   end
   if substr(inln,l,1) \=','| substr(inln,l,1) = '|'  then do
     parse var inln first second therest
     if first = 'rcinclude' then do
       lp = lastpos('\',file)
       nfile = substr(file,1,lp) || second
       call   buildqueue nfile
       inln = ''
      end  /* Do */
     else do
        queue inln
        inln = ''
      end
   end  /* Do */
end /* do */
return

CLEANUP:
   call VExit

exit
