REM @echo off

set pgpassword=k@v1dac

cd C:\Program Files\PostgreSQL\10\bin
ECHO "... ::: REALIZANDO CORTE DE PRESTAMOS EPP NO DEVUELTOS EN FINCAS DE KAVIDAC PRODUCE ::: ..."
ECHO.
ECHO.
ECHO "COBRO POR PRESTAMOS EPP NO DEVUELTOS"
psql -U postgres -d kavidac_finca -c "SELECT epp.tarea_presta()"
ECHO.
ECHO "SALIENDO..."

EXIT.