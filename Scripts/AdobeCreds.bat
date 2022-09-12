for /F "tokens=1,* delims= " %G in ('cmdkey /list ^| findstr Adobe') do cmdkey /delete %H
