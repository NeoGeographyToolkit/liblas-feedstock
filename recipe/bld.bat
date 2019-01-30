:: Spoof OSGEO4W location in Find*.cmake modules
set OSGEO4W_ROOT=%LIBRARY_PREFIX%
set OSGEO4W_HOME=%LIBRARY_PREFIX%

:: Load conda env activate scripts
:: Temporarily spoof CONDA_PREFIX (_build_env now) as PREFIX (_h_env now)
:: Activate scripts reference CONDA_PREFIX as install runtime env
set "_old_conda_prefix=%CONDA_PREFIX%"
set "CONDA_PREFIX=%PREFIX%"
if exist "%PREFIX%\etc\conda\activate.d" (
  for %%G in ("%PREFIX%\etc\conda\activate.d\*.bat") do call "%%G"
)
set "CONDA_PREFIX=%_old_conda_prefix%"
set _old_conda_prefix=

mkdir builddir
cd builddir

:: Do not auto-link with boost filename syntax (in FindBoost.cmake)
:: See: https://github.com/conda-forge/boost-cpp-feedstock/issues/32
::      https://www.boost.org/doc/libs/1_68_0/more/getting_started/windows.html#library-naming
set "CXXFLAGS=/DBOOST_ALL_NO_LIB"

cmake -DCMAKE_INSTALL_PREFIX=%LIBRARY_PREFIX% ^
    -DCMAKE_PREFIX_PATH=%LIBRARY_PREFIX% ^
    -G "Ninja" ^
    -DCMAKE_BUILD_TYPE=Release ^
    -DWITH_GDAL:BOOL=ON ^
    -DWITH_GEOTIFF:BOOL=ON ^
    -DWITH_LASZIP:BOOL=ON ^
    -DWITH_STATIC_LASZIP:BOOL=FALSE ^
    -DWITH_UTILITIES:BOOL=TRUE ^
    -DWITH_TESTS:BOOL=ON ^
    -DBUILD_OSGEO4W:BOOL=FALSE ^
    ..
if %errorlevel% neq 0 exit /b %errorlevel%

cmake --build .
if %errorlevel% neq 0 exit /b %errorlevel%

cmake --build . --target test
if %errorlevel% neq 0 exit /b %errorlevel%

cmake --build . --target install
if %errorlevel% neq 0 exit /b %errorlevel%

:: TODO: Install a wrapper script for .exe launches?
::       See liblas-osgeo4w-*.bat in src


:: -DBoost_INCLUDE_DIR:PATH=%LIBRARY_INC% ^

:: -DBOOST_INCLUDEDIR=%BOOST% ^
:: -DTIFF_INCLUDE_DIR=%OSGEO4W%\include ^
:: -DTIFF_LIBRARY=%OSGEO4W%\lib\libtiff_i.lib ^
:: -DGEOTIFF_INCLUDE_DIR=%OSGEO4W%\include ^
:: -DGEOTIFF_LIBRARY=%OSGEO4W%\lib\geotiff_i.lib ^
:: -DGDAL_INCLUDE_DIR=%OSGEO4W%\include ^
:: -DGDAL_LIBRARY=%OSGEO4W%\lib\gdal_i.lib ^
:: -DLASZIP_INCLUDE_DIR=%OSGEO4W%\include ^
:: -DLASZIP_LIBRARY=%OSGEO4W%\lib\laszip.lib ^