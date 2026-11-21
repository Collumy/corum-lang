@echo off
set JAVA_HOME=C:\Users\collumy\.jdks\jbr-25.0.4.1
set PATH=D:\apps\llvm\bin;%PATH%
"%~dp0corumc\build\install\corum\bin\corum.bat" %*
